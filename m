From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH v4 6/8] sh_eth: remove #ifdef around sh_eth_select_mii()
Date: Thu, 6 Jun 2013 01:16:47 +0400
Message-ID: <201306060116.48096.sergei.shtylyov@cogentembedded.com>
References: <201306060106.51082.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201306060106.51082.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>

We can simply remove #ifdef'fery around sh_eth_select_mii(). We have to annotate
it with '__maybe_unused' then.

Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
[Sergei: added the changelog, reworded the subject, changing the prefix.]
Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
Changes in version 4:
- refreshed the patch;
- added the changelog;
- reworded the subject, changing the prefix.

Changes in version 3:
- annotated sh_eth_select_mii() with '__maybe_unused'.

 drivers/net/ethernet/renesas/sh_eth.c |    6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -313,10 +313,7 @@ static const u16 sh_eth_offset_fast_sh3_
 	[TSU_ADRL31]	= 0x01fc,
 };
 
-#if defined(CONFIG_CPU_SUBTYPE_SH7734) || \
-	defined(CONFIG_CPU_SUBTYPE_SH7763) || \
-	defined(CONFIG_ARCH_R8A7740)
-static void sh_eth_select_mii(struct net_device *ndev)
+static void __maybe_unused sh_eth_select_mii(struct net_device *ndev)
 {
 	u32 value = 0x0;
 	struct sh_eth_private *mdp = netdev_priv(ndev);
@@ -339,7 +336,6 @@ static void sh_eth_select_mii(struct net
 
 	sh_eth_write(ndev, value, RMII_MII);
 }
-#endif
 
 static void __maybe_unused sh_eth_set_duplex(struct net_device *ndev)
 {
