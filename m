From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 00/15] introduce programable flow dissector and cls_flower
Date: Sat,  9 May 2015 15:10:23 +0200
Message-ID: <1431177038-11555-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, tgraf@suug.ch,
	jesse@nicira.com, kaber@trash.net, therbert@google.com,
	edumazet@google.com, alexander.h.duyck@redhat.com,
	hannes@stressinduktion.org, ast@plumgrid.com, daniel@iogearbox.net,
	herbert@gondor.apana.org.au, cwang@twopensource.com,
	john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:32951 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750812AbbEINKn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 09:10:43 -0400
Received: by wgin8 with SMTP id n8so93451173wgi.0
        for <netdev@vger.kernel.org>; Sat, 09 May 2015 06:10:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Per Davem's request, I prepared this patchset which introduces programmable
flow dissector. For current users of flow_keys, there is a wrapper
skb_flow_dissect_flow_keys which maintains the previous behaviour.
For purposes of cls_flower, couple of new dissection keys were introduced.

Note that this dissector can be also eventually used by openvswitch code.

Also, as a next step, I plan to get rid of *skb_flow_get_ports(export)
and *__skb_get_poff as their functionality can be now implemented by
skb_flow_dissect as well.

rfc->v1:
- only rebase

Jiri Pirko (15):
  net: change name of flow_dissector header to match the .c file name
  flow_dissector: remove unused function flow_get_hlen declaration
  net: move *skb_get_poff declarations into correct header
  flow_dissector: fix doc for __skb_get_hash and remove couple of empty
    lines
  net: move __skb_get_hash function declaration to flow_dissector.h
  net: move __skb_tx_hash to skbuff.c
  net: move netdev_pick_tx and dependencies to net/core/dev.c
  flow_dissector: fix doc for skb_get_poff
  flow_dissector: introduce programable flow_dissector
  flow_dissect: use programable dissector in skb_flow_dissect and
    friends
  flow_dissector: add missing header includes
  flow_dissector: introduce support for ipv6 addressses
  flow_dissector: introduce support for Ethernet addresses
  flow_dissector: change port array into src,dst tuple
  tc: introduce Flower classifier

 drivers/net/bonding/bond_main.c                |  20 +-
 drivers/net/ethernet/cisco/enic/enic_clsf.c    |  29 +-
 drivers/net/ethernet/cisco/enic/enic_ethtool.c |  10 +-
 drivers/net/hyperv/netvsc_drv.c                |   8 +-
 include/linux/skbuff.h                         |  11 +-
 include/net/flow_dissector.h                   | 167 ++++++
 include/net/flow_keys.h                        |  61 ---
 include/net/ip.h                               |  10 +-
 include/net/ipv6.h                             |  10 +-
 include/uapi/linux/pkt_cls.h                   |  31 ++
 net/core/dev.c                                 |  78 +++
 net/core/filter.c                              |   1 +
 net/core/flow_dissector.c                      | 380 ++++++++------
 net/core/skbuff.c                              |  28 +
 net/ethernet/eth.c                             |   7 +-
 net/sched/Kconfig                              |  10 +
 net/sched/Makefile                             |   1 +
 net/sched/cls_flow.c                           |  22 +-
 net/sched/cls_flower.c                         | 688 +++++++++++++++++++++++++
 net/sched/sch_choke.c                          |   6 +-
 20 files changed, 1283 insertions(+), 295 deletions(-)
 create mode 100644 include/net/flow_dissector.h
 delete mode 100644 include/net/flow_keys.h
 create mode 100644 net/sched/cls_flower.c

-- 
1.9.3
