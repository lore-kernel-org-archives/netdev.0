From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 09/23] usb-gadget/f_printer: use
	per-attribute show and store methods
Date: Fri, 25 Sep 2015 06:49:46 -0700
Message-ID: <1443189000-13398-10-git-send-email-hch@lst.de>
References: <1443189000-13398-1-git-send-email-hch@lst.de>
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        Pratyush Anand <pratyush.anand@gmail.com>, Felipe Balbi <balbi@ti.com>,
        cluster-devel@redhat.com, target-devel@vger.kernel.org,
        Tejun Heo <tj@kernel.org>, ocfs2-devel@oss.oracle.com
To: Joel Becker <jlbec@evilplan.org>,
        Andrew Morton <akpm@linux-foundation.org>
Return-path: <cluster-devel-bounces@redhat.com>
In-Reply-To: <1443189000-13398-1-git-send-email-hch@lst.de>
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

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/usb/gadget/function/f_printer.c | 31 ++++++++++++-------------------
 1 file changed, 12 insertions(+), 19 deletions(-)

diff --git a/drivers/usb/gadget/function/f_printer.c b/drivers/usb/gadget/function/f_printer.c
index 8e2b6be..29c90d5 100644
--- a/drivers/usb/gadget/function/f_printer.c
+++ b/drivers/usb/gadget/function/f_printer.c
@@ -1148,9 +1148,6 @@ static inline struct f_printer_opts
 			    func_inst.group);
 }
 
-CONFIGFS_ATTR_STRUCT(f_printer_opts);
-CONFIGFS_ATTR_OPS(f_printer_opts);
-
 static void printer_attr_release(struct config_item *item)
 {
 	struct f_printer_opts *opts = to_f_printer_opts(item);
@@ -1160,13 +1157,12 @@ static void printer_attr_release(struct config_item *item)
 
 static struct configfs_item_operations printer_item_ops = {
 	.release	= printer_attr_release,
-	.show_attribute	= f_printer_opts_attr_show,
-	.store_attribute = f_printer_opts_attr_store,
 };
 
-static ssize_t f_printer_opts_pnp_string_show(struct f_printer_opts *opts,
+static ssize_t f_printer_opts_pnp_string_show(struct config_item *item,
 					      char *page)
 {
+	struct f_printer_opts *opts = to_f_printer_opts(item);
 	int result;
 
 	mutex_lock(&opts->lock);
@@ -1176,9 +1172,10 @@ static ssize_t f_printer_opts_pnp_string_show(struct f_printer_opts *opts,
 	return result;
 }
 
-static ssize_t f_printer_opts_pnp_string_store(struct f_printer_opts *opts,
+static ssize_t f_printer_opts_pnp_string_store(struct config_item *item,
 					       const char *page, size_t len)
 {
+	struct f_printer_opts *opts = to_f_printer_opts(item);
 	int result, l;
 
 	mutex_lock(&opts->lock);
@@ -1191,14 +1188,10 @@ static ssize_t f_printer_opts_pnp_string_store(struct f_printer_opts *opts,
 	return result;
 }
 
-static struct f_printer_opts_attribute f_printer_opts_pnp_string =
-	__CONFIGFS_ATTR(pnp_string, S_IRUGO | S_IWUSR,
-			f_printer_opts_pnp_string_show,
-			f_printer_opts_pnp_string_store);
-
-static ssize_t f_printer_opts_q_len_show(struct f_printer_opts *opts,
+static ssize_t f_printer_opts_q_len_show(struct config_item *item,
 					 char *page)
 {
+	struct f_printer_opts *opts = to_f_printer_opts(item);
 	int result;
 
 	mutex_lock(&opts->lock);
@@ -1208,9 +1201,10 @@ static ssize_t f_printer_opts_q_len_show(struct f_printer_opts *opts,
 	return result;
 }
 
-static ssize_t f_printer_opts_q_len_store(struct f_printer_opts *opts,
+static ssize_t f_printer_opts_q_len_store(struct config_item *item,
 					  const char *page, size_t len)
 {
+	struct f_printer_opts *opts = to_f_printer_opts(item);
 	int ret;
 	u16 num;
 
@@ -1231,13 +1225,12 @@ end:
 	return ret;
 }
 
-static struct f_printer_opts_attribute f_printer_opts_q_len =
-	__CONFIGFS_ATTR(q_len, S_IRUGO | S_IWUSR, f_printer_opts_q_len_show,
-			f_printer_opts_q_len_store);
+CONFIGFS_ATTR(f_printer_opts_, pnp_string);
+CONFIGFS_ATTR(f_printer_opts_, q_len);
 
 static struct configfs_attribute *printer_attrs[] = {
-	&f_printer_opts_pnp_string.attr,
-	&f_printer_opts_q_len.attr,
+	&f_printer_opts_attr_pnp_string,
+	&f_printer_opts_attr_q_len,
 	NULL,
 };
 
-- 
1.9.1
