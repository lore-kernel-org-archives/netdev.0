From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 05/23] usb-gadget/f_acm: use per-attribute
	show and store methods
Date: Sat,  3 Oct 2015 15:32:41 +0200
Message-ID: <1443879179-22280-6-git-send-email-hch@lst.de>
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
 drivers/usb/gadget/function/f_acm.c | 26 ++++----------------------
 1 file changed, 4 insertions(+), 22 deletions(-)

diff --git a/drivers/usb/gadget/function/f_acm.c b/drivers/usb/gadget/function/f_acm.c
index be9df09..68b289f 100644
--- a/drivers/usb/gadget/function/f_acm.c
+++ b/drivers/usb/gadget/function/f_acm.c
@@ -776,21 +776,6 @@ static inline struct f_serial_opts *to_f_serial_opts(struct config_item *item)
 			func_inst.group);
 }
 
-CONFIGFS_ATTR_STRUCT(f_serial_opts);
-static ssize_t f_acm_attr_show(struct config_item *item,
-				 struct configfs_attribute *attr,
-				 char *page)
-{
-	struct f_serial_opts *opts = to_f_serial_opts(item);
-	struct f_serial_opts_attribute *f_serial_opts_attr =
-		container_of(attr, struct f_serial_opts_attribute, attr);
-	ssize_t ret = 0;
-
-	if (f_serial_opts_attr->show)
-		ret = f_serial_opts_attr->show(opts, page);
-	return ret;
-}
-
 static void acm_attr_release(struct config_item *item)
 {
 	struct f_serial_opts *opts = to_f_serial_opts(item);
@@ -800,20 +785,17 @@ static void acm_attr_release(struct config_item *item)
 
 static struct configfs_item_operations acm_item_ops = {
 	.release                = acm_attr_release,
-	.show_attribute		= f_acm_attr_show,
 };
 
-static ssize_t f_acm_port_num_show(struct f_serial_opts *opts, char *page)
+static ssize_t f_acm_port_num_show(struct config_item *item, char *page)
 {
-	return sprintf(page, "%u\n", opts->port_num);
+	return sprintf(page, "%u\n", to_f_serial_opts(item)->port_num);
 }
 
-static struct f_serial_opts_attribute f_acm_port_num =
-	__CONFIGFS_ATTR_RO(port_num, f_acm_port_num_show);
-
+CONFIGFS_ATTR_RO(f_acm_port_, num);
 
 static struct configfs_attribute *acm_attrs[] = {
-	&f_acm_port_num.attr,
+	&f_acm_port_attr_num,
 	NULL,
 };
 
-- 
1.9.1
