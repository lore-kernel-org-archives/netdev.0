From: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
Subject: [PATCH 07/23] usb-gadget/f_loopback: use per-attribute show and store methods
Date: Fri, 25 Sep 2015 06:49:44 -0700
Message-ID: <1443189000-13398-8-git-send-email-hch@lst.de>
References: <1443189000-13398-1-git-send-email-hch@lst.de>
Cc: Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Pratyush Anand <pratyush.anand-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	target-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cluster-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	ocfs2-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Joel Becker <jlbec-aKy9MeLSZ9dg9hUCZPvPmw@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1443189000-13398-1-git-send-email-hch-jcswGhMUV9g@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
---
 drivers/usb/gadget/function/f_loopback.c | 32 ++++++++++++--------------------
 1 file changed, 12 insertions(+), 20 deletions(-)

diff --git a/drivers/usb/gadget/function/f_loopback.c b/drivers/usb/gadget/function/f_loopback.c
index 6e2fe63..d4ef421 100644
--- a/drivers/usb/gadget/function/f_loopback.c
+++ b/drivers/usb/gadget/function/f_loopback.c
@@ -413,9 +413,6 @@ static inline struct f_lb_opts *to_f_lb_opts(struct config_item *item)
 			    func_inst.group);
 }
 
-CONFIGFS_ATTR_STRUCT(f_lb_opts);
-CONFIGFS_ATTR_OPS(f_lb_opts);
-
 static void lb_attr_release(struct config_item *item)
 {
 	struct f_lb_opts *lb_opts = to_f_lb_opts(item);
@@ -425,12 +422,11 @@ static void lb_attr_release(struct config_item *item)
 
 static struct configfs_item_operations lb_item_ops = {
 	.release		= lb_attr_release,
-	.show_attribute		= f_lb_opts_attr_show,
-	.store_attribute	= f_lb_opts_attr_store,
 };
 
-static ssize_t f_lb_opts_qlen_show(struct f_lb_opts *opts, char *page)
+static ssize_t f_lb_opts_qlen_show(struct config_item *item, char *page)
 {
+	struct f_lb_opts *opts = to_f_lb_opts(item);
 	int result;
 
 	mutex_lock(&opts->lock);
@@ -440,9 +436,10 @@ static ssize_t f_lb_opts_qlen_show(struct f_lb_opts *opts, char *page)
 	return result;
 }
 
-static ssize_t f_lb_opts_qlen_store(struct f_lb_opts *opts,
+static ssize_t f_lb_opts_qlen_store(struct config_item *item,
 				    const char *page, size_t len)
 {
+	struct f_lb_opts *opts = to_f_lb_opts(item);
 	int ret;
 	u32 num;
 
@@ -463,13 +460,9 @@ end:
 	return ret;
 }
 
-static struct f_lb_opts_attribute f_lb_opts_qlen =
-	__CONFIGFS_ATTR(qlen, S_IRUGO | S_IWUSR,
-			f_lb_opts_qlen_show,
-			f_lb_opts_qlen_store);
-
-static ssize_t f_lb_opts_bulk_buflen_show(struct f_lb_opts *opts, char *page)
+static ssize_t f_lb_opts_bulk_buflen_show(struct config_item *item, char *page)
 {
+	struct f_lb_opts *opts = to_f_lb_opts(item);
 	int result;
 
 	mutex_lock(&opts->lock);
@@ -479,9 +472,10 @@ static ssize_t f_lb_opts_bulk_buflen_show(struct f_lb_opts *opts, char *page)
 	return result;
 }
 
-static ssize_t f_lb_opts_bulk_buflen_store(struct f_lb_opts *opts,
+static ssize_t f_lb_opts_bulk_buflen_store(struct config_item *item,
 				    const char *page, size_t len)
 {
+	struct f_lb_opts *opts = to_f_lb_opts(item);
 	int ret;
 	u32 num;
 
@@ -502,14 +496,12 @@ end:
 	return ret;
 }
 
-static struct f_lb_opts_attribute f_lb_opts_bulk_buflen =
-	__CONFIGFS_ATTR(buflen, S_IRUGO | S_IWUSR,
-			f_lb_opts_bulk_buflen_show,
-			f_lb_opts_bulk_buflen_store);
+CONFIGFS_ATTR(f_lb_opts_, qlen);
+CONFIGFS_ATTR(f_lb_opts_, bulk_buflen);
 
 static struct configfs_attribute *lb_attrs[] = {
-	&f_lb_opts_qlen.attr,
-	&f_lb_opts_bulk_buflen.attr,
+	&f_lb_opts_attr_qlen,
+	&f_lb_opts_attr_bulk_buflen,
 	NULL,
 };
 
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
