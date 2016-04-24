From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 1/2] sh_eth: use EDMR_SRST_GETHER in sh_eth_check_reset()
Date: Sun, 24 Apr 2016 23:45:23 +0300
Message-ID: <10299839.69pLJTKjhc@wasted.cogentembedded.com>
References: <16246598.T4zYgEztZA@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-renesas-soc@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <16246598.T4zYgEztZA@wasted.cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

sh_eth_check_reset() uses a bare number where EDMR_SRST_GETHER would fit,
i.e. the receive/trasmit software reset bits that comprise EDMR_SRST_GETHER
read as 1  while the corresponding reset is in progress and thus, when both
are 0, the reset is complete.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/ethernet/renesas/sh_eth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -899,7 +899,7 @@ static int sh_eth_check_reset(struct net
 	int cnt = 100;
 
 	while (cnt > 0) {
-		if (!(sh_eth_read(ndev, EDMR) & 0x3))
+		if (!(sh_eth_read(ndev, EDMR) & EDMR_SRST_GETHER))
 			break;
 		mdelay(1);
 		cnt--;
