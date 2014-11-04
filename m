From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCH net 0/5] Implement ndo_gso_check() for vxlan nics
Date: Tue,  4 Nov 2014 13:56:37 -0800
Message-ID: <1415138202-1197-1-git-send-email-joestringer@nicira.com>
Cc: sathya.perla@emulex.com, jeffrey.t.kirsher@intel.com,
	linux.nics@intel.com, amirv@mellanox.com, shahed.shaikh@qlogic.com,
	Dept-GELinuxNICDev@qlogic.com, therbert@google.com,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Most NICs that report NETIF_F_GSO_UDP_TUNNEL support VXLAN, and not other
UDP-based encapsulation protocols where the format and size of the header may
differ. This patch series implements ndo_gso_check() for these NICs,
restricting the GSO handling to something that looks and smells like VXLAN.

Implementation shamelessly stolen from Tom Herbert (with minor fixups):
http://thread.gmane.org/gmane.linux.network/332428/focus=333111

If there are particular differences for your driver on actual support, I'd like
to hear about it. I adjusted the i40e driver to report support with tunnel
headers of up to 64 octets, perhaps there are other specifics that I've missed.

Joe Stringer (5):
  be2net: Implement ndo_gso_check()
  i40e: Implement ndo_gso_check()
  fm10k: Implement ndo_gso_check()
  net/mlx4_en: Implement ndo_gso_check()
  qlcnic: Implement ndo_gso_check()

 drivers/net/ethernet/emulex/benet/be_main.c      |   12 ++++++++++++
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c  |   12 ++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_main.c      |   14 +++++++++++++-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c   |   12 ++++++++++++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |   12 ++++++++++++
 5 files changed, 61 insertions(+), 1 deletion(-)

--
1.7.10.4
