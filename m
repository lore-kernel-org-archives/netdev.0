From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 0/9] sched: introduce vlan action
Date: Tue, 18 Nov 2014 22:37:35 +0100
Message-ID: <1416346664-9290-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, pshelar@nicira.com,
	therbert@google.com, edumazet@google.com, willemb@google.com,
	dborkman@redhat.com, mst@redhat.com, fw@strlen.de,
	Paul.Durrant@citrix.com, tgraf@suug.ch, cwang@twopensource.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:38569 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754178AbaKRVhr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2014 16:37:47 -0500
Received: by mail-wg0-f41.google.com with SMTP id y19so9717303wgg.28
        for <netdev@vger.kernel.org>; Tue, 18 Nov 2014 13:37:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko (9):
  openvswitch: actions: use skb_postpull_rcsum when possible
  vlan: make __vlan_hwaccel_put_tag return void
  vlan: kill vlan_put_tag helper
  vlan: rename __vlan_put_tag to vlan_insert_tag_set_proto
  vlan: introduce *vlan_hwaccel_push_inside helpers
  vlan: introduce __vlan_insert_tag helper which does not free skb
  net: move make_writable helper into common code
  net: move vlan pop/push functions into common code
  sched: introduce vlan action

 drivers/net/bonding/bond_alb.c              |  17 +--
 drivers/net/bonding/bond_main.c             |  12 +-
 drivers/net/ethernet/emulex/benet/be_main.c |   6 +-
 drivers/net/usb/cdc_mbim.c                  |   2 +-
 drivers/net/vxlan.c                         |  22 +--
 drivers/scsi/fcoe/fcoe.c                    |   6 +-
 include/linux/if_vlan.h                     | 107 +++++++++-----
 include/linux/skbuff.h                      |   3 +
 include/net/tc_act/tc_vlan.h                |  27 ++++
 include/uapi/linux/tc_act/tc_vlan.h         |  35 +++++
 net/8021q/vlan_dev.c                        |   2 +-
 net/bridge/br_vlan.c                        |   4 +-
 net/core/dev.c                              |   8 +-
 net/core/netpoll.c                          |   4 +-
 net/core/skbuff.c                           | 107 ++++++++++++++
 net/ipv4/geneve.c                           |  12 +-
 net/openvswitch/actions.c                   | 130 ++++-------------
 net/openvswitch/datapath.c                  |   5 +-
 net/openvswitch/vport-gre.c                 |  12 +-
 net/sched/Kconfig                           |  11 ++
 net/sched/Makefile                          |   1 +
 net/sched/act_vlan.c                        | 207 ++++++++++++++++++++++++++++
 22 files changed, 525 insertions(+), 215 deletions(-)
 create mode 100644 include/net/tc_act/tc_vlan.h
 create mode 100644 include/uapi/linux/tc_act/tc_vlan.h
 create mode 100644 net/sched/act_vlan.c

-- 
1.9.3
