From: santosh nayak <santoshprasadnayak-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 3/3] net: orinoco: add error handling for failed kmalloc().
Date: Thu, 22 Mar 2012 12:42:41 +0530
Message-ID: <1332400361-11176-1-git-send-email-santoshprasadnayak@gmail.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Santosh Nayak <santoshprasadnayak-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Santosh Nayak <santoshprasadnayak-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

With flag 'GFP_ATOMIC', probability of allocation failure is more.
Add error handling after kmalloc() call to avoid null dereference.

Signed-off-by: Santosh Nayak <santoshprasadnayak-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/wireless/orinoco/main.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/orinoco/main.c b/drivers/net/wireless/orinoco/main.c
index dd6c64a..24a768b 100644
--- a/drivers/net/wireless/orinoco/main.c
+++ b/drivers/net/wireless/orinoco/main.c
@@ -1336,6 +1336,10 @@ static void qbuf_scan(struct orinoco_private *priv, void *buf,
 	unsigned long flags;
 
 	sd = kmalloc(sizeof(*sd), GFP_ATOMIC);
+	if (!sd) {
+		printk(KERN_ERR "%s: failed to alloc memory\n", __func__);
+		return;
+	}
 	sd->buf = buf;
 	sd->len = len;
 	sd->type = type;
@@ -1353,6 +1357,10 @@ static void qabort_scan(struct orinoco_private *priv)
 	unsigned long flags;
 
 	sd = kmalloc(sizeof(*sd), GFP_ATOMIC);
+	if (!sd) {
+		printk(KERN_ERR "%s: failed to alloc memory\n", __func__);
+		return;
+	}
 	sd->len = -1; /* Abort */
 
 	spin_lock_irqsave(&priv->scan_lock, flags);
-- 
1.7.4.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
