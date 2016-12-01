From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] net: renesas: ravb: unintialized return value
Date: Thu, 1 Dec 2016 23:57:44 +0300
Message-ID: <20161201205744.GB10701@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Yoshihiro Kaneko <ykaneko0929@gmail.com>,
        Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>,
        Simon Horman <horms+renesas@verge.net.au>,
        Wolfram Sang <wsa+renesas@sang-engineering.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Philippe Reynes <tremyfr@gmail.com>,
        Niklas =?iso-8859-1?Q?S=F6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>,
        Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Johan Hovold <johan@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:20564 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753335AbcLAU6c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 15:58:32 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We want to set the other "err" variable here so that we can return it
later.  My version of GCC misses this issue but I caught it with a
static checker.

Fixes: 9f70eb339f52 ("net: ethernet: renesas: ravb: fix fixed-link phydev leaks")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
Applies to the net tree for 4.10.

diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
index 2c0357c..92d7692 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -1016,8 +1016,6 @@ static int ravb_phy_init(struct net_device *ndev)
 	 * at this time.
 	 */
 	if (priv->chip_id == RCAR_GEN3) {
-		int err;
-
 		err = phy_set_max_speed(phydev, SPEED_100);
 		if (err) {
 			netdev_err(ndev, "failed to limit PHY to 100Mbit/s\n");
