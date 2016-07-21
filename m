From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/9] mlxsw: implement port mirroring offload
Date: Thu, 21 Jul 2016 10:19:11 +0200
Message-ID: <1469089160-4239-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, eladr@mellanox.com,
	idosch@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	jhs@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:32888 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751028AbcGUITX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 04:19:23 -0400
Received: by mail-wm0-f67.google.com with SMTP id o80so1649960wme.0
        for <netdev@vger.kernel.org>; Thu, 21 Jul 2016 01:19:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This patchset introduces tc matchall classifier and its offload
to Spectrum hardware. In combination with mirred action, defined port mirroring
setup is offloaded by mlxsw/spectrum driver.

The commands used for creating mirror ports:

# ingress mirroring using matchall
tc qdisc  add dev eth25 handle ffff: ingress
tc filter add dev eth25 parent ffff:            \
        matchall skip_sw                        \
        action mirred egress mirror             \
        dev eth27

# egress mirroring using matchall
tc qdisc add dev eth25 handle 1: root prio
tc filter add dev eth25 parent 1:               \
        matchall skip_sw                        \
        action mirred egress mirror             \
        dev eth27

These patches contain:
 - Resource query implementation
 - Hardware port mirorring support for spectrum.
 - Definition of the matchall traffic classifier.
 - General support for hw-offloading for that classifier.
 - Specific spectrum implementaion for matchall offloading.

Jiri Pirko (1):
  net/sched: introduce Match-all classifier

Nogah Frankel (2):
  mlxsw: pci: Add resources query implementation.
  mlxsw: pci: Add max span resources to resources query

Yotam Gigi (6):
  net/sched: Add match-all classifier hw offloading.
  mlxsw: reg: Add Shared Buffer Internal Buffer register
  mlxsw: reg: Add Monitoring Port Analyzer Table register
  mlxsw: reg: Add the Monitoring Port Analyzer register
  net/sched: act_mirred: Add helper inlines to access tcf_mirred info.
  mlxsw: spectrum: Add support in matchall mirror TC offloading

 drivers/net/ethernet/mellanox/mlxsw/cmd.h      |  32 ++
 drivers/net/ethernet/mellanox/mlxsw/core.c     |  10 +-
 drivers/net/ethernet/mellanox/mlxsw/core.h     |  11 +-
 drivers/net/ethernet/mellanox/mlxsw/pci.c      |  65 +++-
 drivers/net/ethernet/mellanox/mlxsw/reg.h      | 163 +++++++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 466 ++++++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h |  44 +++
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c |   1 +
 include/linux/netdevice.h                      |   2 +
 include/net/pkt_cls.h                          |  11 +
 include/net/tc_act/tc_mirred.h                 |   9 +
 include/uapi/linux/pkt_cls.h                   |  12 +
 net/sched/Kconfig                              |  10 +
 net/sched/Makefile                             |   1 +
 net/sched/cls_matchall.c                       | 318 +++++++++++++++++
 15 files changed, 1150 insertions(+), 5 deletions(-)
 create mode 100644 net/sched/cls_matchall.c

-- 
2.5.5
