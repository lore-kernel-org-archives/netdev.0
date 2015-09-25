From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 14/23] usb-gadget/f_obex: use per-attribute
	show and store methods
Date: Fri, 25 Sep 2015 06:49:51 -0700
Message-ID: <1443189000-13398-15-git-send-email-hch@lst.de>
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
 drivers/usb/gadget/function/f_obex.c | 26 ++++----------------------
 1 file changed, 4 insertions(+), 22 deletions(-)

diff --git a/drivers/usb/gadget/function/f_obex.c b/drivers/usb/gadget/function/f_obex.c
index 5460426..f6f1e6b 100644
--- a/drivers/usb/gadget/function/f_obex.c
+++ b/drivers/usb/gadget/function/f_obex.c
@@ -395,22 +395,6 @@ static inline struct f_serial_opts *to_f_serial_opts(struct config_item *item)
 			    func_inst.group);
 }
 
-CONFIGFS_ATTR_STRUCT(f_serial_opts);
-static ssize_t f_obex_attr_show(struct config_item *item,
-				struct configfs_attribute *attr,
-				char *page)
-{
-	struct f_serial_opts *opts = to_f_serial_opts(item);
-	struct f_serial_opts_attribute *f_serial_opts_attr =
-		container_of(attr, struct f_serial_opts_attribute, attr);
-	ssize_t ret = 0;
-
-	if (f_serial_opts_attr->show)
-		ret = f_serial_opts_attr->show(opts, page);
-
-	return ret;
-}
-
 static void obex_attr_release(struct config_item *item)
 {
 	struct f_serial_opts *opts = to_f_serial_opts(item);
@@ -420,19 +404,17 @@ static void obex_attr_release(struct config_item *item)
 
 static struct configfs_item_operations obex_item_ops = {
 	.release	= obex_attr_release,
-	.show_attribute = f_obex_attr_show,
 };
 
-static ssize_t f_obex_port_num_show(struct f_serial_opts *opts, char *page)
+static ssize_t f_obex_port_num_show(struct config_item *item, char *page)
 {
-	return sprintf(page, "%u\n", opts->port_num);
+	return sprintf(page, "%u\n", to_f_serial_opts(item)->port_num);
 }
 
-static struct f_serial_opts_attribute f_obex_port_num =
-	__CONFIGFS_ATTR_RO(port_num, f_obex_port_num_show);
+CONFIGFS_ATTR_RO(f_obex_, port_num);
 
 static struct configfs_attribute *acm_attrs[] = {
-	&f_obex_port_num.attr,
+	&f_obex_attr_port_num,
 	NULL,
 };
 
-- 
1.9.1
