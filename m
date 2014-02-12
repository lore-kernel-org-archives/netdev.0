From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH 03/14] net: axienet: Support for RGMII
Date: Wed, 12 Feb 2014 16:55:37 +0100
Message-ID: <e8678ed4b94770ffc754327a2ea89311ea3e3de0.1392220536.git.michal.simek@xilinx.com>
References: <cover.1392220536.git.michal.simek@xilinx.com>
Content-Type: multipart/signed;
    boundary="=_mimegpg-monstr-desktop-2223-1392220581-0001";
    micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: Srikanth Thokala <sthokal@xilinx.com>,
	Srikanth Thokala <srikanth.thokala@xilinx.com>,
	Michal Simek <monstr@monstr.eu>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	John Linn <John.Linn@xilinx.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1392220536.git.michal.simek@xilinx.com>
In-Reply-To: <cover.1392220536.git.michal.simek@xilinx.com>
References: <cover.1392220536.git.michal.simek@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a MIME GnuPG-signed message.  If you see this text, it means that
your E-mail or Usenet software does not support MIME signed messages.
The Internet standard for MIME PGP messages, RFC 2015, was published in 1996.
To open this message correctly you will need to install E-mail or Usenet
software that supports modern Internet standards.

--=_mimegpg-monstr-desktop-2223-1392220581-0001

From: Srikanth Thokala <srikanth.thokala@xilinx.com>

This patch adds support for the RGMII. The h/w configuration
parameter C_PHY_TYPE, which represents the interface configured in
the design, is used to differentiate various interfaces supported
by AXI Ethernet.

Signed-off-by: Srikanth Thokala <sthokal@xilinx.com>
Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---

 drivers/net/ethernet/xilinx/xilinx_axienet_main.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index 4bfdf8c..3966d83 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -925,9 +925,16 @@ static int axienet_open(struct net_device *ndev)
 		return ret;

 	if (lp->phy_node) {
-		lp->phy_dev = of_phy_connect(lp->ndev, lp->phy_node,
+		if (lp->phy_type == XAE_PHY_TYPE_GMII) {
+			lp->phy_dev = of_phy_connect(lp->ndev, lp->phy_node,
 					     axienet_adjust_link, 0,
 					     PHY_INTERFACE_MODE_GMII);
+		} else if (lp->phy_type == XAE_PHY_TYPE_RGMII_2_0) {
+			lp->phy_dev = of_phy_connect(lp->ndev, lp->phy_node,
+					     axienet_adjust_link, 0,
+					     PHY_INTERFACE_MODE_RGMII_ID);
+		}
+
 		if (!lp->phy_dev) {
 			dev_err(lp->dev, "of_phy_connect() failed\n");
 			return -ENODEV;
--
1.8.2.3


--=_mimegpg-monstr-desktop-2223-1392220581-0001
Content-Type: application/pgp-signature
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAlL7maUACgkQykllyylKDCFWTACfZ+9XETsbsCpmzlXkiOJtgDWm
lYEAnjT6a4xdWg+iWHo+8M39X5rgLIMj
=l9MR
-----END PGP SIGNATURE-----

--=_mimegpg-monstr-desktop-2223-1392220581-0001--
