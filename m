From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 0/9] Mellanox 100G SRIOV offloads vlan push/pop
Date: Thu, 22 Sep 2016 20:01:40 +0300
Message-ID: <1474563709-17943-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen-Zion <hadarh@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Andy Gospodarek <gospo@cumulusnetworks.com>,
        Jesse Brandeburg <jesse.brandeburg@intel.com>,
        John Fastabend <john.r.fastabend@intel.com>,
        Amir Vadai <amirv@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:48994 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S964968AbcIVRCQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 13:02:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

>From Or Gerlitz:

This series further enhances the SRIOV TC offloads of mlx5 to handle
the TC vlan push and pop actions. This serves a common use-case in
virtualization systems where the virtual switch add (push) vlan tags
to packets sent from VMs and removes (pop) vlan tags before the packet
is received by the VM. We use the new E-Switch switchdev mode and the
TC vlan action to achieve that also in SW defined SRIOV environments by
offloading TC rules that contain this action along with forwarding
(TC mirred/redirect action) the packet.

In the first patch we add some helpers to access the TC vlan action info
by offloading drivers. The next five patches don't add any new functionality,
they do some refactoring and cleanups in the current code to be used next.

The seventh patch deals with supporting vlans by the mlx5 e-switch in switchdev
mode. The eighth patch does the vlan action offload from TC and the last patch
adds matching for vlans as typically required by TC flows that involve vlan
pop action.

The series was applied on top of commit 524605e "cxgb4: Convert to use simple_open()"

Thanks.

Or Gerlitz (9):
  net_sched: act_vlan: add helper inlines to access tcf_vlan info
  net/mlx5: E-Switch, Set the vport when registering the uplink rep
  net/mlx5: E-Switch, Set vport representor fields explicitly on
    registration
  net/mlx5: E-Switch, Allow fine tuning of eswitch vport push/pop vlan
  net/mlx5: Put elements related to offloaded TC rule in one struct
  net/mlx5e: Refactor retrival of skb from rx completion element (cqe)
  net/mlx5: E-Switch, Support VLAN actions in the offloads mode
  net/mlx5e: Add TC vlan action for SRIOV offloads
  net/mlx5e: Add TC vlan match parsing

 drivers/net/ethernet/mellanox/mlx5/core/en.h       |   1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  27 ++-
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |  74 +++++--
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    | 109 ++++++----
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  |  33 ++-
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h  |  38 +++-
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c | 222 +++++++++++++++++++--
 include/net/tc_act/tc_vlan.h                       |  25 +++
 8 files changed, 446 insertions(+), 83 deletions(-)

-- 
2.7.4
