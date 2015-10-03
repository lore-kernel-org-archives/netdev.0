From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 16/23] usb-gadget/f_serial: use per-attribute show and store methods
Date: Sat,  3 Oct 2015 15:32:52 +0200
Message-ID: <1443879179-22280-17-git-send-email-hch@lst.de>
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
Received: from bombadil.infradead.org ([198.137.202.9]:59696 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752713AbbJCNhf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Oct 2015 09:37:35 -0400
In-Reply-To: <1443879179-22280-1-git-send-email-hch@lst.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To simplify the configfs interface and remove boilerplate code that also
causes binary bloat.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Andrzej Pietrasiewicz <andrzej.p@samsung.com>
---
 drivers/usb/gadget/function/f_serial.c | 26 ++++----------------------
 1 file changed, 4 insertions(+), 22 deletions(-)

diff --git a/drivers/usb/gadget/function/f_serial.c b/drivers/usb/gadget/function/f_serial.c
index 1d162e2..ec837f4 100644
--- a/drivers/usb/gadget/function/f_serial.c
+++ b/drivers/usb/gadget/function/f_serial.c
@@ -266,22 +266,6 @@ static inline struct f_serial_opts *to_f_serial_opts(struct config_item *item)
 			    func_inst.group);
 }
 
-CONFIGFS_ATTR_STRUCT(f_serial_opts);
-static ssize_t f_serial_attr_show(struct config_item *item,
-				  struct configfs_attribute *attr,
-				  char *page)
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
 static void serial_attr_release(struct config_item *item)
 {
 	struct f_serial_opts *opts = to_f_serial_opts(item);
@@ -291,19 +275,17 @@ static void serial_attr_release(struct config_item *item)
 
 static struct configfs_item_operations serial_item_ops = {
 	.release	= serial_attr_release,
-	.show_attribute = f_serial_attr_show,
 };
 
-static ssize_t f_serial_port_num_show(struct f_serial_opts *opts, char *page)
+static ssize_t f_serial_port_num_show(struct config_item *item, char *page)
 {
-	return sprintf(page, "%u\n", opts->port_num);
+	return sprintf(page, "%u\n", to_f_serial_opts(item)->port_num);
 }
 
-static struct f_serial_opts_attribute f_serial_port_num =
-	__CONFIGFS_ATTR_RO(port_num, f_serial_port_num_show);
+CONFIGFS_ATTR_RO(f_serial_, port_num);
 
 static struct configfs_attribute *acm_attrs[] = {
-	&f_serial_port_num.attr,
+	&f_serial_attr_port_num,
 	NULL,
 };
 
-- 
1.9.1
