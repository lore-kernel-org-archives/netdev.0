From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/13] igb: Implement support to power sfp cage and turn on I2C
Date: Thu,  4 Apr 2013 04:37:53 -0700
Message-ID: <1365075480-20183-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1365075480-20183-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	=?UTF-8?q?Aur=C3=A9lien=20Guillaume?= <footplus@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:29187 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758861Ab3DDLiX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Apr 2013 07:38:23 -0400
In-Reply-To: <1365075480-20183-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>

Based on original patch from Aur=C3=A9lien Guillaume <footplus@gmail.co=
m>

This patch adds support to turn on I2C, with sfp cage powered.

CC: Aur=C3=A9lien Guillaume <footplus@gmail.com>
Signed-off-by: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net=
/ethernet/intel/igb/e1000_82575.c
index 12b1d84..856364a 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -1420,9 +1420,10 @@ static s32 igb_setup_serdes_link_82575(struct e1=
000_hw *hw)
 	 */
 	wr32(E1000_SCTL, E1000_SCTL_DISABLE_SERDES_LOOPBACK);
=20
-	/* power on the sfp cage if present */
+	/* power on the sfp cage if present and turn on I2C */
 	ctrl_ext =3D rd32(E1000_CTRL_EXT);
 	ctrl_ext &=3D ~E1000_CTRL_EXT_SDP3_DATA;
+	ctrl_ext |=3D E1000_CTRL_I2C_ENA;
 	wr32(E1000_CTRL_EXT, ctrl_ext);
=20
 	ctrl_reg =3D rd32(E1000_CTRL);
--=20
1.7.11.7
