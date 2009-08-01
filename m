From: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>
Subject: [PATCH 4/5] drivers/net/wireless: Use DIV_ROUND_CLOSEST
Date: Sat, 1 Aug 2009 21:50:31 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0908012149570.25693@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>

The kernel.h macro DIV_ROUND_CLOSEST performs the computation (x + d/2)/d
but is perhaps more readable.

The semantic patch that makes this change is as follows:
(http://www.emn.fr/x-info/coccinelle/)

// <smpl>
@haskernel@
@@

#include <linux/kernel.h>

@depends on haskernel@
expression x,__divisor;
@@

- (((x) + ((__divisor) / 2)) / (__divisor))
+ DIV_ROUND_CLOSEST(x,__divisor)
// </smpl>

Signed-off-by: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>

---
 drivers/net/wireless/strip.c        |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/strip.c b/drivers/net/wireless/strip.c
index 73300c2..8eabb56 100644
--- a/drivers/net/wireless/strip.c
+++ b/drivers/net/wireless/strip.c
@@ -1550,9 +1550,12 @@ static int strip_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (time_after(jiffies, strip_info->pps_timer + HZ)) {
 		unsigned long t = jiffies - strip_info->pps_timer;
-		unsigned long rx_pps_count = (strip_info->rx_pps_count * HZ * 8 + t / 2) / t;
-		unsigned long tx_pps_count = (strip_info->tx_pps_count * HZ * 8 + t / 2) / t;
-		unsigned long sx_pps_count = (strip_info->sx_pps_count * HZ * 8 + t / 2) / t;
+		unsigned long rx_pps_count =
+			DIV_ROUND_CLOSEST(strip_info->rx_pps_count*HZ*8, t);
+		unsigned long tx_pps_count =
+			DIV_ROUND_CLOSEST(strip_info->tx_pps_count*HZ*8, t);
+		unsigned long sx_pps_count =
+			DIV_ROUND_CLOSEST(strip_info->sx_pps_count*HZ*8, t);
 
 		strip_info->pps_timer = jiffies;
 		strip_info->rx_pps_count = 0;
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
