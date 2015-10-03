From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 07/23] usb-gadget/f_loopback: use
	per-attribute show and store methods
Date: Sat,  3 Oct 2015 15:32:43 +0200
Message-ID: <1443879179-22280-8-git-send-email-hch@lst.de>
References: <1443879179-22280-1-git-send-email-hch@lst.de>
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        Pratyush Anand <pratyush.anand@gmail.com>,
        Pantelis Antoniou <pantelis.antoniou@konsulko.com>,
        Felipe Balbi <balbi@ti.com>, cluster-devel@redhat.com,
        Tejun Heo <tj@kernel.org>, target-devel@vger.kernel.org,
        Andrzej Pietrasiewicz <andrzej.p@samsung.com>,
        ocfs2-devel@oss.oracle.com
To: Joel Becker <jlbec@evilplan.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Nicholas Bellinger <nab@linux-iscsi.org>
Return-path: <cluster-devel-bounces@redhat.com>
In-Reply-To: <1443879179-22280-1-git-send-email-hch@lst.de>
List-Unsubscribe: <https://www.redhat.com/mailman/options/cluster-devel>,
	<mailto:cluster-devel-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/cluster-devel>
List-Post: <mailto:cluster-devel@redhat.com>
List-Help: <mailto:cluster-devel-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/cluster-devel>,
	<mailto:cluster-devel-request@redhat.com?subject=subscribe>
Sender: cluster-devel-bounces@redhat.com
Errors-To: cluster-devel-bounces@redhat.com
List-Id: netdev.vger.kernel.org

To simplify the configfs interface and remove boilerplate code that also
causes binary bloat.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Andrzej Pietrasiewicz <andrzej.p@samsung.com>
---
 drivers/usb/gadget/function/f_loopback.c | 31 ++++++++++++-------------------
 1 file changed, 12 insertions(+), 19 deletions(-)

diff --git a/drivers/usb/gadget/function/f_loopback.c b/drivers/usb/gadget/function/f_loopback.c
index 6e2fe63..b9d8f05 100644
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
 
@@ -463,13 +460,11 @@ end:
 	return ret;
 }
 
-static struct f_lb_opts_attribute f_lb_opts_qlen =
-	__CONFIGFS_ATTR(qlen, S_IRUGO | S_IWUSR,
-			f_lb_opts_qlen_show,
-			f_lb_opts_qlen_store);
+CONFIGFS_ATTR(f_lb_opts_, qlen);
 
-static ssize_t f_lb_opts_bulk_buflen_show(struct f_lb_opts *opts, char *page)
+static ssize_t f_lb_opts_bulk_buflen_show(struct config_item *item, char *page)
 {
+	struct f_lb_opts *opts = to_f_lb_opts(item);
 	int result;
 
 	mutex_lock(&opts->lock);
@@ -479,9 +474,10 @@ static ssize_t f_lb_opts_bulk_buflen_show(struct f_lb_opts *opts, char *page)
 	return result;
 }
 
-static ssize_t f_lb_opts_bulk_buflen_store(struct f_lb_opts *opts,
+static ssize_t f_lb_opts_bulk_buflen_store(struct config_item *item,
 				    const char *page, size_t len)
 {
+	struct f_lb_opts *opts = to_f_lb_opts(item);
 	int ret;
 	u32 num;
 
@@ -502,14 +498,11 @@ end:
 	return ret;
 }
 
-static struct f_lb_opts_attribute f_lb_opts_bulk_buflen =
-	__CONFIGFS_ATTR(buflen, S_IRUGO | S_IWUSR,
-			f_lb_opts_bulk_buflen_show,
-			f_lb_opts_bulk_buflen_store);
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
