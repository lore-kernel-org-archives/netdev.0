From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: [PATCH 2/12]: wext: Make adjust_priv_size() take a "struct
 iw_point *".
Date: Tue, 17 Jun 2008 00:53:15 -0700 (PDT)
Message-ID: <20080617.005315.215862748.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mokuno-DfbDroY8Xu1L9jVzuh4AOg@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


wext: Make adjust_priv_size() take a "struct iw_point *".

Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 net/wireless/wext.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/wireless/wext.c b/net/wireless/wext.c
index e83d74a..cd2cf9f 100644
--- a/net/wireless/wext.c
+++ b/net/wireless/wext.c
@@ -512,9 +512,9 @@ static int get_priv_size(__u16 args)
 /*
  * Re-calculate the size of private arguments
  */
-static int adjust_priv_size(__u16 args, union iwreq_data *wrqu)
+static int adjust_priv_size(__u16 args, struct iw_point *iwp)
 {
-	int	num = wrqu->data.length;
+	int	num = iwp->length;
 	int	max = args & IW_PRIV_SIZE_MASK;
 	int	type = (args & IW_PRIV_TYPE_MASK) >> 12;
 
@@ -976,7 +976,7 @@ static int ioctl_private_call(struct net_device *dev, struct ifreq *ifr,
 			 * avoid leaking kernel bits outside. */
 			if (!(descr->get_args & IW_PRIV_SIZE_FIXED)) {
 				extra_size = adjust_priv_size(descr->get_args,
-							      &(iwr->u));
+							      &(iwr->u.data));
 			}
 
 			err = copy_to_user(iwr->u.data.pointer, extra,
-- 
1.5.5.1.308.g1fbb5

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
