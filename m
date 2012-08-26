From: Wei Yongjun <weiyj.lk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] wl3501_cs: use is_broadcast_ether_addr() instead of memcmp()
Date: Sun, 26 Aug 2012 09:24:21 +0800
Message-ID: <CAPgLHd94RKJg7MwY8sf7S00aukdmrS8LHGvvfWv_iSZZ9TMiuw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>

Using is_broadcast_ether_addr() instead of directly use
memcmp() to determine if the ethernet address is broadcast
address.

Signed-off-by: Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>
---
 drivers/net/wireless/wl3501_cs.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/wireless/wl3501_cs.c b/drivers/net/wireless/wl3501_cs.c
index 00f6e69..730186d 100644
--- a/drivers/net/wireless/wl3501_cs.c
+++ b/drivers/net/wireless/wl3501_cs.c
@@ -1520,13 +1520,12 @@ static int wl3501_set_wap(struct net_device *dev, struct iw_request_info *info,
 			  union iwreq_data *wrqu, char *extra)
 {
 	struct wl3501_card *this = netdev_priv(dev);
-	static const u8 bcast[ETH_ALEN] = { 255, 255, 255, 255, 255, 255 };
 	int rc = -EINVAL;
 
 	/* FIXME: we support other ARPHRDs...*/
 	if (wrqu->ap_addr.sa_family != ARPHRD_ETHER)
 		goto out;
-	if (!memcmp(bcast, wrqu->ap_addr.sa_data, ETH_ALEN)) {
+	if (is_broadcast_ether_addr(wrqu->ap_addr.sa_data)) {
 		/* FIXME: rescan? */
 	} else
 		memcpy(this->bssid, wrqu->ap_addr.sa_data, ETH_ALEN);


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
