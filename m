From: akinobu.mita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Subject: [patch -v2 11/23] airo: use simple_read_from_buffer
Date: Mon, 02 Jun 2008 08:13:40 +0900
Message-ID: <20080601231543.372911291@gmail.com>
References: <20080601231329.223608711@gmail.com>
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline; filename=airo-use-simple-read-from-buffer.patch
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Akinobu Mita <akinobu.mita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 drivers/net/wireless/airo.c |   15 +++------------
 1 file changed, 3 insertions(+), 12 deletions(-)

Index: 2.6-git/drivers/net/wireless/airo.c
===================================================================
--- 2.6-git.orig/drivers/net/wireless/airo.c
+++ 2.6-git/drivers/net/wireless/airo.c
@@ -4560,22 +4560,13 @@ static ssize_t proc_read( struct file *f
 			  size_t len,
 			  loff_t *offset )
 {
-	loff_t pos = *offset;
-	struct proc_data *priv = (struct proc_data*)file->private_data;
+	struct proc_data *priv = file->private_data;
 
 	if (!priv->rbuffer)
 		return -EINVAL;
 
-	if (pos < 0)
-		return -EINVAL;
-	if (pos >= priv->readlen)
-		return 0;
-	if (len > priv->readlen - pos)
-		len = priv->readlen - pos;
-	if (copy_to_user(buffer, priv->rbuffer + pos, len))
-		return -EFAULT;
-	*offset = pos + len;
-	return len;
+	return simple_read_from_buffer(buffer, len, offset, priv->rbuffer,
+					priv->readlen);
 }
 
 /*

-- 
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
