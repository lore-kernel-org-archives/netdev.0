From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv2 net 0/4] Implement ndo_gso_check() for vxlan nics
Date: Thu, 13 Nov 2014 16:38:11 -0800
Message-ID: <1415925495-59312-1-git-send-email-joestringer@nicira.com>
Cc: sathya.perla@emulex.com, shahed.shaikh@qlogic.com,
	amirv@mellanox.com, Dept-GELinuxNICDev@qlogic.com,
	therbert@google.com, gerlitz.or@gmail.com,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Most NICs that report NETIF_F_GSO_UDP_TUNNEL support VXLAN, and not other
UDP-based encapsulation protocols where the format and size of the header may
differ. This patch series implements a generic ndo_gso_check() for detecting
VXLAN, then reuses it for these NICs.

Implementation shamelessly stolen from Tom Herbert (with minor fixups):
http://thread.gmane.org/gmane.linux.network/332428/focus=333111

v2: Drop i40e/fm10k patches (code diverged; handling separately).
    Refactor common code into vxlan_gso_check() helper.
    Minor style fixes.

Joe Stringer (4):
  net: Add vxlan_gso_check() helper
  be2net: Implement ndo_gso_check()
  net/mlx4_en: Implement ndo_gso_check()
  qlcnic: Implement ndo_gso_check()

 drivers/net/ethernet/emulex/benet/be_main.c      |    6 ++++++
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c   |    6 ++++++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    6 ++++++
 drivers/net/vxlan.c                              |   13 +++++++++++++
 include/net/vxlan.h                              |    2 ++
 5 files changed, 33 insertions(+)

-- 
1.7.10.4
