From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 09/23] usb-gadget/f_printer: use per-attribute
	show and store methods
Date: Sat,  3 Oct 2015 15:32:45 +0200
Message-ID: <1443879179-22280-10-git-send-email-hch@lst.de>
References: <1443879179-22280-1-git-send-email-hch@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
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
Return-path: <ocfs2-devel-bounces@oss.oracle.com>
In-Reply-To: <1443879179-22280-1-git-send-email-hch@lst.de>
List-Unsubscribe: <https://oss.oracle.com/mailman/listinfo/ocfs2-devel>,
	<mailto:ocfs2-devel-request@oss.oracle.com?subject=unsubscribe>
List-Archive: <http://oss.oracle.com/pipermail/ocfs2-devel>
List-Post: <mailto:ocfs2-devel@oss.oracle.com>
List-Help: <mailto:ocfs2-devel-request@oss.oracle.com?subject=help>
List-Subscribe: <https://oss.oracle.com/mailman/listinfo/ocfs2-devel>,
	<mailto:ocfs2-devel-request@oss.oracle.com?subject=subscribe>
Sender: ocfs2-devel-bounces@oss.oracle.com
Errors-To: ocfs2-devel-bounces@oss.oracle.com
List-Id: netdev.vger.kernel.org

To simplify the configfs interface and remove boilerplate code that also
causes binary bloat.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Andrzej Pietrasiewicz <andrzej.p@samsung.com>
---
 drivers/usb/gadget/function/f_printer.c | 30 ++++++++++++------------------
 1 file changed, 12 insertions(+), 18 deletions(-)

diff --git a/drivers/usb/gadget/function/f_printer.c b/drivers/usb/gadget/function/f_printer.c
index 8e2b6be..3a37846 100644
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
@@ -1191,14 +1188,12 @@ static ssize_t f_printer_opts_pnp_string_store(struct f_printer_opts *opts,
 	return result;
 }
 
-static struct f_printer_opts_attribute f_printer_opts_pnp_string =
-	__CONFIGFS_ATTR(pnp_string, S_IRUGO | S_IWUSR,
-			f_printer_opts_pnp_string_show,
-			f_printer_opts_pnp_string_store);
+CONFIGFS_ATTR(f_printer_opts_, pnp_string);
 
-static ssize_t f_printer_opts_q_len_show(struct f_printer_opts *opts,
+static ssize_t f_printer_opts_q_len_show(struct config_item *item,
 					 char *page)
 {
+	struct f_printer_opts *opts = to_f_printer_opts(item);
 	int result;
 
 	mutex_lock(&opts->lock);
@@ -1208,9 +1203,10 @@ static ssize_t f_printer_opts_q_len_show(struct f_printer_opts *opts,
 	return result;
 }
 
-static ssize_t f_printer_opts_q_len_store(struct f_printer_opts *opts,
+static ssize_t f_printer_opts_q_len_store(struct config_item *item,
 					  const char *page, size_t len)
 {
+	struct f_printer_opts *opts = to_f_printer_opts(item);
 	int ret;
 	u16 num;
 
@@ -1231,13 +1227,11 @@ end:
 	return ret;
 }
 
-static struct f_printer_opts_attribute f_printer_opts_q_len =
-	__CONFIGFS_ATTR(q_len, S_IRUGO | S_IWUSR, f_printer_opts_q_len_show,
-			f_printer_opts_q_len_store);
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
