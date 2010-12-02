From: Andy Shevchenko <andy.shevchenko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1/2] wireless: ray_cs: use '%pm' format option to print MAC
Date: Thu,  2 Dec 2010 14:45:07 +0200
Message-ID: <1291293908-29180-1-git-send-email-andy.shevchenko@gmail.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Andy Shevchenko <andy.shevchenko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Andy Shevchenko <andy.shevchenko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 drivers/net/wireless/ray_cs.c |   14 ++++----------
 1 files changed, 4 insertions(+), 10 deletions(-)

diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index 2b1cbba..0764d1a 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -1776,11 +1776,8 @@ static void ray_update_multi_list(struct net_device *dev, int all)
 		/* Copy the kernel's list of MC addresses to card */
 		netdev_for_each_mc_addr(ha, dev) {
 			memcpy_toio(p, ha->addr, ETH_ALEN);
-			dev_dbg(&link->dev,
-			      "ray_update_multi add addr %02x%02x%02x%02x%02x%02x\n",
-			      ha->addr[0], ha->addr[1],
-			      ha->addr[2], ha->addr[3],
-			      ha->addr[4], ha->addr[5]);
+			dev_dbg(&link->dev, "ray_update_multi add addr %pm\n",
+				ha->addr);
 			p += ETH_ALEN;
 			i++;
 		}
@@ -2015,11 +2012,8 @@ static irqreturn_t ray_interrupt(int irq, void *dev_id)
 				memcpy_fromio(&local->bss_id,
 					      prcs->var.rejoin_net_complete.
 					      bssid, ADDRLEN);
-				dev_dbg(&link->dev,
-				      "ray_cs new BSSID = %02x%02x%02x%02x%02x%02x\n",
-				      local->bss_id[0], local->bss_id[1],
-				      local->bss_id[2], local->bss_id[3],
-				      local->bss_id[4], local->bss_id[5]);
+				dev_dbg(&link->dev, "ray_cs new BSSID = %pm\n",
+					local->bss_id);
 				if (!sniffer)
 					authenticate(local);
 			}
-- 
1.7.2.3

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
