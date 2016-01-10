From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 2/2] sh_eth: stop reading ECMR in sh_eth_dev_init()
Date: Mon, 11 Jan 2016 00:28:14 +0300
Message-ID: <1452487360.1PLDn6dh2G@wasted.cogentembedded.com>
References: <5859243.yu8qorLmay@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <5859243.yu8qorLmay@wasted.cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The code in sh_eth_dev_init()  twiddling the ECMR bits always looked a bit
strange to me:  if one intends to respect 'mdp->duplex', why save old value
of the ECMR.DM bit? As all the other bits are zeroed anyway, we don't really
need to read ECMR before writing to it.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/ethernet/renesas/sh_eth.c |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

Index: net/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net/drivers/net/ethernet/renesas/sh_eth.c
@@ -1289,7 +1289,6 @@ static int sh_eth_dev_init(struct net_de
 {
 	int ret = 0;
 	struct sh_eth_private *mdp = netdev_priv(ndev);
-	u32 val;
 
 	/* Soft Reset */
 	ret = sh_eth_reset(ndev);
@@ -1342,10 +1341,8 @@ static int sh_eth_dev_init(struct net_de
 	}
 
 	/* PAUSE Prohibition */
-	val = (sh_eth_read(ndev, ECMR) & ECMR_DM) |
-		ECMR_ZPF | (mdp->duplex ? ECMR_DM : 0) | ECMR_TE | ECMR_RE;
-
-	sh_eth_write(ndev, val, ECMR);
+	sh_eth_write(ndev, ECMR_ZPF | (mdp->duplex ? ECMR_DM : 0) |
+		     ECMR_TE | ECMR_RE, ECMR);
 
 	if (mdp->cd->set_rate)
 		mdp->cd->set_rate(ndev);

