From: Wei Yongjun <weiyj.lk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] wireless: use is_broadcast_ether_addr() instead of memcmp()
Date: Sun, 26 Aug 2012 08:54:41 +0800
Message-ID: <CAPgLHd9fEihp_Mgz19ueHLS13=4PKUNDHywT7++HeGf+k++hHA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: j@w1.fi, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>

Using is_broadcast_ether_addr() instead of directly use
memcmp() to determine if the ethernet address is broadcast
address.

spatch with a semantic match is used to found this problem.
(http://coccinelle.lip6.fr/)


Signed-off-by: Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>
---
 drivers/net/wireless/hostap/hostap_ioctl.c | 15 +++++----------
 1 file changed, 5 insertions(+), 10 deletions(-)

diff --git a/drivers/net/wireless/hostap/hostap_ioctl.c b/drivers/net/wireless/hostap/hostap_ioctl.c
index 18054d9..ac07473 100644
--- a/drivers/net/wireless/hostap/hostap_ioctl.c
+++ b/drivers/net/wireless/hostap/hostap_ioctl.c
@@ -6,6 +6,7 @@
 #include <linux/ethtool.h>
 #include <linux/if_arp.h>
 #include <linux/module.h>
+#include <linux/etherdevice.h>
 #include <net/lib80211.h>
 
 #include "hostap_wlan.h"
@@ -3221,8 +3222,7 @@ static int prism2_ioctl_siwencodeext(struct net_device *dev,
 		return -EINVAL;
 
 	addr = ext->addr.sa_data;
-	if (addr[0] == 0xff && addr[1] == 0xff && addr[2] == 0xff &&
-	    addr[3] == 0xff && addr[4] == 0xff && addr[5] == 0xff) {
+	if (is_broadcast_ether_addr(addr)) {
 		sta_ptr = NULL;
 		crypt = &local->crypt_info.crypt[i];
 	} else {
@@ -3394,8 +3394,7 @@ static int prism2_ioctl_giwencodeext(struct net_device *dev,
 		i--;
 
 	addr = ext->addr.sa_data;
-	if (addr[0] == 0xff && addr[1] == 0xff && addr[2] == 0xff &&
-	    addr[3] == 0xff && addr[4] == 0xff && addr[5] == 0xff) {
+	if (is_broadcast_ether_addr(addr)) {
 		sta_ptr = NULL;
 		crypt = &local->crypt_info.crypt[i];
 	} else {
@@ -3458,9 +3457,7 @@ static int prism2_ioctl_set_encryption(local_info_t *local,
 	    param->u.crypt.key_len)
 		return -EINVAL;
 
-	if (param->sta_addr[0] == 0xff && param->sta_addr[1] == 0xff &&
-	    param->sta_addr[2] == 0xff && param->sta_addr[3] == 0xff &&
-	    param->sta_addr[4] == 0xff && param->sta_addr[5] == 0xff) {
+	if (is_broadcast_ether_addr(param->sta_addr)) {
 		if (param->u.crypt.idx >= WEP_KEYS)
 			return -EINVAL;
 		sta_ptr = NULL;
@@ -3593,9 +3590,7 @@ static int prism2_ioctl_get_encryption(local_info_t *local,
 	if (max_key_len < 0)
 		return -EINVAL;
 
-	if (param->sta_addr[0] == 0xff && param->sta_addr[1] == 0xff &&
-	    param->sta_addr[2] == 0xff && param->sta_addr[3] == 0xff &&
-	    param->sta_addr[4] == 0xff && param->sta_addr[5] == 0xff) {
+	if (is_broadcast_ether_addr(param->sta_addr)) {
 		sta_ptr = NULL;
 		if (param->u.crypt.idx >= WEP_KEYS)
 			param->u.crypt.idx = local->crypt_info.tx_keyidx;

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
