From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH 1/2] net: emaclite: Not necessary to call devm_iounmap
Date: Thu, 12 Sep 2013 09:05:10 +0200
Message-ID: <196d8368eee2d45eeeab40e96e2971f78ed8a79b.1378969499.git.michal.simek@xilinx.com>
Content-Type: multipart/signed;
    boundary="=_mimegpg-monstr-desktop-28863-1378969511-0001";
    micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: Michal Simek <monstr@monstr.eu>,
	"David S. Miller" <davem@davemloft.net>,
	Jens Renner <renner@efe-gmbh.de>,
	Libo Chen <libo.chen@huawei.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a MIME GnuPG-signed message.  If you see this text, it means that
your E-mail or Usenet software does not support MIME signed messages.
The Internet standard for MIME PGP messages, RFC 2015, was published in 1996.
To open this message correctly you will need to install E-mail or Usenet
software that supports modern Internet standards.

--=_mimegpg-monstr-desktop-28863-1378969511-0001

devm_iounmap is called automatically.

Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---
 drivers/net/ethernet/xilinx/xilinx_emaclite.c | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
index 4c619ea..de39098 100644
--- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
+++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
@@ -1075,14 +1075,9 @@ static int xemaclite_send(struct sk_buff *orig_skb, struct net_device *dev)
  * This function un maps the IO region of the Emaclite device and frees the net
  * device.
  */
-static void xemaclite_remove_ndev(struct net_device *ndev,
-				  struct platform_device *pdev)
+static void xemaclite_remove_ndev(struct net_device *ndev)
 {
 	if (ndev) {
-		struct net_local *lp = netdev_priv(ndev);
-
-		if (lp->base_addr)
-			devm_iounmap(&pdev->dev, lp->base_addr);
 		free_netdev(ndev);
 	}
 }
@@ -1214,7 +1209,7 @@ static int xemaclite_of_probe(struct platform_device *ofdev)
 	return 0;

 error:
-	xemaclite_remove_ndev(ndev, ofdev);
+	xemaclite_remove_ndev(ndev);
 	return rc;
 }

@@ -1248,7 +1243,7 @@ static int xemaclite_of_remove(struct platform_device *of_dev)
 		of_node_put(lp->phy_node);
 	lp->phy_node = NULL;

-	xemaclite_remove_ndev(ndev, of_dev);
+	xemaclite_remove_ndev(ndev);

 	return 0;
 }
--
1.8.2.3


--=_mimegpg-monstr-desktop-28863-1378969511-0001
Content-Type: application/pgp-signature
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAlIxZ6cACgkQykllyylKDCEjbgCfaaMzqF5DXiOtdKAtcgsHNaDS
9+sAnRo/iLgK2CSYe1VJZ0oPIzc/AAnV
=a75j
-----END PGP SIGNATURE-----

--=_mimegpg-monstr-desktop-28863-1378969511-0001--
