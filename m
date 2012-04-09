From: Julia Lawall <Julia.Lawall-L2FTfq7BK8M@public.gmane.org>
Subject: [PATCH] net/wireless/wext-core.c: add missing kfree
Date: Mon,  9 Apr 2012 11:01:09 +0200
Message-ID: <1333962069-20801-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall-L2FTfq7BK8M@public.gmane.org>

Free extra as done in the error-handling code just above.

Signed-off-by: Julia Lawall <Julia.Lawall-L2FTfq7BK8M@public.gmane.org>

---
 net/wireless/wext-core.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/wireless/wext-core.c b/net/wireless/wext-core.c
index 9f544c9..22adfeb 100644
--- a/net/wireless/wext-core.c
+++ b/net/wireless/wext-core.c
@@ -781,8 +781,10 @@ static int ioctl_standard_iw_point(struct iw_point *iwp, unsigned int cmd,
 		if (cmd == SIOCSIWENCODEEXT) {
 			struct iw_encode_ext *ee = (void *) extra;
 
-			if (iwp->length < sizeof(*ee) + ee->key_len)
-				return -EFAULT;
+			if (iwp->length < sizeof(*ee) + ee->key_len) {
+				err = -EFAULT;
+				goto out;
+			}
 		}
 	}
 

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
