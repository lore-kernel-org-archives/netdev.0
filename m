From: Andy Shevchenko <andriy.shevchenko-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: [PATCH v1] net/sunrpc/cache: simplify code by using hex_pack_byte()
Date: Thu, 12 Dec 2013 15:49:21 +0200
Message-ID: <1386856161-29889-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

hex_pack_byte() is a fast way to convert a byte in its ASCII representation. We
may use it instead of custom approach.

Signed-off-by: Andy Shevchenko <andriy.shevchenko-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
---
 net/sunrpc/cache.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index a72de07..0877db0 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -1111,9 +1111,7 @@ void qword_addhex(char **bpp, int *lp, char *buf, int blen)
 		*bp++ = 'x';
 		len -= 2;
 		while (blen && len >= 2) {
-			unsigned char c = *buf++;
-			*bp++ = '0' + ((c&0xf0)>>4) + (c>=0xa0)*('a'-'9'-1);
-			*bp++ = '0' + (c&0x0f) + ((c&0x0f)>=0x0a)*('a'-'9'-1);
+			bp = hex_byte_pack(bp, *buf++);
 			len -= 2;
 			blen--;
 		}
-- 
1.8.4.4

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
