From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 15/23] usb-gadget/f_phonet: use
	per-attribute show and store methods
Date: Fri, 25 Sep 2015 06:49:52 -0700
Message-ID: <1443189000-13398-16-git-send-email-hch@lst.de>
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
 drivers/usb/gadget/function/f_phonet.c | 25 ++++---------------------
 1 file changed, 4 insertions(+), 21 deletions(-)

diff --git a/drivers/usb/gadget/function/f_phonet.c b/drivers/usb/gadget/function/f_phonet.c
index c0c3ef2..c029ef6 100644
--- a/drivers/usb/gadget/function/f_phonet.c
+++ b/drivers/usb/gadget/function/f_phonet.c
@@ -589,21 +589,6 @@ static inline struct f_phonet_opts *to_f_phonet_opts(struct config_item *item)
 			func_inst.group);
 }
 
-CONFIGFS_ATTR_STRUCT(f_phonet_opts);
-static ssize_t f_phonet_attr_show(struct config_item *item,
-				struct configfs_attribute *attr,
-				char *page)
-{
-	struct f_phonet_opts *opts = to_f_phonet_opts(item);
-	struct f_phonet_opts_attribute *f_phonet_opts_attr =
-		container_of(attr, struct f_phonet_opts_attribute, attr);
-	ssize_t ret = 0;
-
-	if (f_phonet_opts_attr->show)
-		ret = f_phonet_opts_attr->show(opts, page);
-	return ret;
-}
-
 static void phonet_attr_release(struct config_item *item)
 {
 	struct f_phonet_opts *opts = to_f_phonet_opts(item);
@@ -613,19 +598,17 @@ static void phonet_attr_release(struct config_item *item)
 
 static struct configfs_item_operations phonet_item_ops = {
 	.release		= phonet_attr_release,
-	.show_attribute		= f_phonet_attr_show,
 };
 
-static ssize_t f_phonet_ifname_show(struct f_phonet_opts *opts, char *page)
+static ssize_t f_phonet_ifname_show(struct config_item *item, char *page)
 {
-	return gether_get_ifname(opts->net, page, PAGE_SIZE);
+	return gether_get_ifname(to_f_phonet_opts(item)->net, page, PAGE_SIZE);
 }
 
-static struct f_phonet_opts_attribute f_phonet_ifname =
-	__CONFIGFS_ATTR_RO(ifname, f_phonet_ifname_show);
+CONFIGFS_ATTR_RO(f_phonet_, ifname);
 
 static struct configfs_attribute *phonet_attrs[] = {
-	&f_phonet_ifname.attr,
+	&f_phonet_attr_ifname,
 	NULL,
 };
 
-- 
1.9.1
