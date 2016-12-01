From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: [PATCH net-next V2 0/8] Offloading tc rules using underline Hardware device
Date: Thu,  1 Dec 2016 14:06:32 +0200
Message-ID: <1480594000-8428-1-git-send-email-hadarh@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:45284 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1758534AbcLANC0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 08:02:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds flower classifier support in offloading tc rules when the
Software ingress device is different from the Hardware ingress device, 
such as when dealing with IP tunnels  

The first two patches are a small fixes to flower, checking the skip_hw flag
wasn't set before calling the Hardware offloading functions which will try to
offload the rule.

The next two patches are infrastructure patches, a preparation for the fourth
patch which is adding support in flower to offload rules when the ingress
device is not a Hardware device and therefore can't offload.
In this case ndo_setup_tc is called with the mirred (egress) device.

The last three patchs are adding mlx5e support to offload rules using the new
"egress_device" flag.

Thanks,
Hadar

Changes from v0:
- check if CONFIG_NET_CLS_ACT is defined befor calling tc_action_ops get_dev()

Hadar Hen Zion (8):
  net/sched: Add separate check for skip_hw flag
  net/sched: cls_flower: Try to offload only if skip_hw flag isn't set
  net/sched: cls_flower: Provide a filter to replace/destroy hardware
    filter functions
  net/sched: act_mirred: Add new tc_action_ops get_dev()
  net/sched: cls_flower: Add offload support using egress Hardware
    device
  net/mlx5e: Bring back representor's ndos that were accidentally
    removed
  net/mlx5e: Save the represntor netdevice as part of the representor
  net/mlx5e: Support adding ingress tc rule when egress device flag is
    set

 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c   | 25 +++++--
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h  |  3 +-
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c | 12 ++-
 include/linux/netdevice.h                          |  1 +
 include/net/act_api.h                              |  2 +
 include/net/pkt_cls.h                              | 21 +++++-
 net/sched/act_mirred.c                             | 12 +++
 net/sched/cls_api.c                                | 24 ++++++
 net/sched/cls_flower.c                             | 87 ++++++++++++----------
 10 files changed, 135 insertions(+), 54 deletions(-)

-- 
1.8.3.1
