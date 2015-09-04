From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net 1/1] r8169: fix sleepable allocation during netdevice
 stats retrieval.
Date: Fri, 4 Sep 2015 22:59:04 +0200
Message-ID: <20150904205904.GA32346@electric-eye.fr.zoreil.com>
References: <55E9A518.3080906@gmail.com>
 <20150904.113657.2146226970417029162.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pomidorabelisima@gmail.com, netdev@vger.kernel.org,
	vinschen@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:57036 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751117AbbIDU7h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2015 16:59:37 -0400
Content-Disposition: inline
In-Reply-To: <20150904.113657.2146226970417029162.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net/core/net-sysfs.c::netstat_show fetches statistics under dev_base_lock.

Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=104031
Fixes: 6e85d5ad36a2 ("r8169: Add values missing in @get_stats64 from HW counters")
Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Corinna Vinschen <vinschen@redhat.com>
---

 Applies against davem's net as of f1ccbfce2fc787981d1182d09c1f6b67766783a8.

 drivers/net/ethernet/realtek/r8169.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 24dcbe6..56829ea 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -2200,7 +2200,7 @@ static struct rtl8169_counters *rtl8169_map_counters(struct net_device *dev,
 	struct rtl8169_counters *counters;
 	u32 cmd;
 
-	counters = dma_alloc_coherent(d, sizeof(*counters), paddr, GFP_KERNEL);
+	counters = dma_alloc_coherent(d, sizeof(*counters), paddr, GFP_ATOMIC);
 	if (counters) {
 		RTL_W32(CounterAddrHigh, (u64)*paddr >> 32);
 		cmd = (u64)*paddr & DMA_BIT_MASK(32);
-- 
2.4.3
