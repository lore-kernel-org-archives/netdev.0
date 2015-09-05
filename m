From: romieu@fr.zoreil.com
Subject: [PATCH net 2/3] r8169: move rtl_reset_counters_cond before the hardware counters helpers.
Date: Sat,  5 Sep 2015 14:18:53 +0200
Message-ID: <b910cb70e9dc41f505532745204b8f147435f8ca.1441454454.git.romieu@fr.zoreil.com>
References: <cover.1441454454.git.romieu@fr.zoreil.com>
Cc: David Miller <davem@davemloft.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	pomidorabelisima@gmail.com, vinschen@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:57785 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752310AbbIEMTx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Sep 2015 08:19:53 -0400
In-Reply-To: <cover.1441454454.git.romieu@fr.zoreil.com>
In-Reply-To: <cover.1441454454.git.romieu@fr.zoreil.com>
References: <cover.1441454454.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Corinna Vinschen <vinschen@redhat.com>
Cc: pomidorabelisima@gmail.com
---
 drivers/net/ethernet/realtek/r8169.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 73a60a7..c0a5edb 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -2190,6 +2190,13 @@ static int rtl8169_get_sset_count(struct net_device *dev, int sset)
 	}
 }
 
+DECLARE_RTL_COND(rtl_reset_counters_cond)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	return RTL_R32(CounterAddrLow) & CounterReset;
+}
+
 static struct rtl8169_counters *rtl8169_map_counters(struct net_device *dev,
 						     dma_addr_t *paddr,
 						     u32 counter_cmd)
@@ -2224,13 +2231,6 @@ static void rtl8169_unmap_counters (struct net_device *dev,
 	dma_free_coherent(d, sizeof(*counters), counters, paddr);
 }
 
-DECLARE_RTL_COND(rtl_reset_counters_cond)
-{
-	void __iomem *ioaddr = tp->mmio_addr;
-
-	return RTL_R32(CounterAddrLow) & CounterReset;
-}
-
 static bool rtl8169_reset_counters(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
-- 
2.4.3
