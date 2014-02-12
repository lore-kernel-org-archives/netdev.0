From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH 08/14] net: axienet: Removed checkpatch errors/warnings
Date: Wed, 12 Feb 2014 16:55:42 +0100
Message-ID: <75b669c0a947effe74b291093abfa8c71f83736a.1392220536.git.michal.simek@xilinx.com>
References: <cover.1392220536.git.michal.simek@xilinx.com>
Content-Type: multipart/signed;
    boundary="=_mimegpg-monstr-desktop-2289-1392220617-0001";
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

--=_mimegpg-monstr-desktop-2289-1392220617-0001

From: Srikanth Thokala <srikanth.thokala@xilinx.com>

Removed checkpatch.pl errors and warnings.

Signed-off-by: Srikanth Thokala <sthokal@xilinx.com>
Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---

 drivers/net/ethernet/xilinx/xilinx_axienet_main.c | 20 ++++++++++----------
 drivers/net/ethernet/xilinx/xilinx_axienet_mdio.c | 21 +++++++++++----------
 2 files changed, 21 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index 9cc9e59..6059a0f 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -444,8 +444,8 @@ static void __axienet_device_reset(struct axienet_local *lp,
 	while (axienet_dma_in32(lp, offset) & XAXIDMA_CR_RESET_MASK) {
 		udelay(1);
 		if (--timeout == 0) {
-			dev_err(dev, "axienet_device_reset DMA "
-				"reset timeout!\n");
+			netdev_err(lp->ndev,
+				"axienet_device_reset DMA reset timeout!\n");
 			break;
 		}
 	}
@@ -484,8 +484,8 @@ static void axienet_device_reset(struct net_device *ndev)
 	}

 	if (axienet_dma_bd_init(ndev)) {
-		dev_err(&ndev->dev, "axienet_device_reset descriptor "
-			"allocation failed\n");
+		netdev_err(ndev,
+			"axienet_device_reset descriptor allocation failed\n");
 	}

 	axienet_status = axienet_ior(lp, XAE_RCW1_OFFSET);
@@ -560,8 +560,8 @@ static void axienet_adjust_link(struct net_device *ndev)
 			lp->last_link = link_state;
 			phy_print_status(phy);
 		} else {
-			dev_err(&ndev->dev, "Error setting Axi Ethernet "
-				"mac speed\n");
+			netdev_err(ndev,
+				   "Error setting Axi Ethernet mac speed\n");
 		}
 	}
 }
@@ -1238,8 +1238,8 @@ axienet_ethtools_set_pauseparam(struct net_device *ndev,
 	struct axienet_local *lp = netdev_priv(ndev);

 	if (netif_running(ndev)) {
-		printk(KERN_ERR	"%s: Please stop netif before applying "
-		       "configruation\n", ndev->name);
+		netdev_err(ndev,
+			   "Please stop netif before applying configuration\n");
 		return -EFAULT;
 	}

@@ -1295,8 +1295,8 @@ static int axienet_ethtools_set_coalesce(struct net_device *ndev,
 	struct axienet_local *lp = netdev_priv(ndev);

 	if (netif_running(ndev)) {
-		printk(KERN_ERR	"%s: Please stop netif before applying "
-		       "configruation\n", ndev->name);
+		netdev_err(ndev,
+			"Please stop netif before applying configuration\n");
 		return -EFAULT;
 	}

diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_mdio.c b/drivers/net/ethernet/xilinx/xilinx_axienet_mdio.c
index 64b4639..ef0a20c 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_mdio.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_mdio.c
@@ -161,19 +161,19 @@ int axienet_mdio_setup(struct axienet_local *lp, struct device_node *np)

 	np1 = of_find_node_by_name(NULL, "cpu");
 	if (!np1) {
-		printk(KERN_WARNING "%s(): Could not find CPU device node.",
-		       __func__);
-		printk(KERN_WARNING "Setting MDIO clock divisor to "
-		       "default %d\n", DEFAULT_CLOCK_DIVISOR);
+		netdev_warn(lp->ndev, "Could not find CPU device node.");
+		netdev_warn(lp->ndev,
+			    "Setting MDIO clock divisor to default %d\n",
+			    DEFAULT_CLOCK_DIVISOR);
 		clk_div = DEFAULT_CLOCK_DIVISOR;
 		goto issue;
 	}
 	property_p = (u32 *) of_get_property(np1, "clock-frequency", NULL);
 	if (!property_p) {
-		printk(KERN_WARNING "%s(): Could not find CPU property: "
-		       "clock-frequency.", __func__);
-		printk(KERN_WARNING "Setting MDIO clock divisor to "
-		       "default %d\n", DEFAULT_CLOCK_DIVISOR);
+		netdev_warn(lp->ndev,
+			 "Could not find clock ethernet controller property.");
+		netdev_warn(lp->ndev, "Setting MDIO clock divisor to default %d\n",
+							DEFAULT_CLOCK_DIVISOR);
 		clk_div = DEFAULT_CLOCK_DIVISOR;
 		of_node_put(np1);
 		goto issue;
@@ -187,8 +187,9 @@ int axienet_mdio_setup(struct axienet_local *lp, struct device_node *np)
 	if (host_clock % (MAX_MDIO_FREQ * 2))
 		clk_div++;

-	printk(KERN_DEBUG "%s(): Setting MDIO clock divisor to %u based "
-	       "on %u Hz host clock.\n", __func__, clk_div, host_clock);
+	netdev_dbg(lp->ndev,
+		"Setting MDIO clock divisor to %u based on %u Hz host clock.\n",
+		clk_div, host_clock);

 	of_node_put(np1);
 issue:
--
1.8.2.3


--=_mimegpg-monstr-desktop-2289-1392220617-0001
Content-Type: application/pgp-signature
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAlL7mckACgkQykllyylKDCFqswCeJyv8acQ674I41AvMxo+PCUfY
/30Ani2QG4Z5lZQjUnly+DTjh7NbDQDt
=HMbC
-----END PGP SIGNATURE-----

--=_mimegpg-monstr-desktop-2289-1392220617-0001--
