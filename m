From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 15/23] usb-gadget/f_phonet: use per-attribute show and store methods
Date: Sat,  3 Oct 2015 15:32:51 +0200
Message-ID: <1443879179-22280-16-git-send-email-hch@lst.de>
References: <1443879179-22280-1-git-send-email-hch@lst.de>
Cc: Felipe Balbi <balbi@ti.com>,
	Andrzej Pietrasiewicz <andrzej.p@samsung.com>,
	Tejun Heo <tj@kernel.org>,
	Pratyush Anand <pratyush.anand@gmail.com>,
	Pantelis Antoniou <pantelis.antoniou@konsulko.com>,
	target-devel@vger.kernel.org, cluster-devel@redhat.com,
	ocfs2-devel@oss.oracle.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Joel Becker <jlbec@evilplan.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Nicholas Bellinger <nab@linux-iscsi.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:59669 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752786AbbJCNhm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Oct 2015 09:37:42 -0400
In-Reply-To: <1443879179-22280-1-git-send-email-hch@lst.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To simplify the configfs interface and remove boilerplate code that also
causes binary bloat.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Andrzej Pietrasiewicz <andrzej.p@samsung.com>
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
