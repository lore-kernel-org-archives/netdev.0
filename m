From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH v2 15/15] configfs: make config_item_type const
Date: Mon, 16 Oct 2017 17:18:54 +0200
Message-ID: <1508167134-6243-16-git-send-email-bhumirks@gmail.com>
References: <1508167134-6243-1-git-send-email-bhumirks@gmail.com>
Cc: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, rjw@rjwysocki.net, lenb@kernel.org,
        alexander.shishkin@linux.intel.com, jic23@kernel.org,
        knaack.h@gmx.de, lars@metafoo.de, pmeerw@pmeerw.net,
        dledford@redhat.com, sean.hefty@intel.com,
        hal.rosenstock@gmail.com, hch@lst.de, sagi@grimberg.me,
        kishon@ti.com, bhelgaas@google.com, nab@linux-iscsi.org,
        balbi@kernel.org, gregkh@linuxfoundation.org,
        laurent.pinchart@ideasonboard.com, jlbec@evilplan.org,
        ccaulfie@redhat.com, teigland@redhat.com, mfasheh@versity.com,
        linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-iio@vger.kernel.org, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org, linux-nvme@lists.infradead.org,
        linux-pci@vger.kernel.org, linux-scsi@vger.kernel.org,
        target-devel@vger.kernel.org, linux-usb@vger.kernel.org,
        cluster-devel@redh
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:53711 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753925AbdJPPTx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 11:19:53 -0400
In-Reply-To: <1508167134-6243-1-git-send-email-bhumirks@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make config_item_type structures const as they are either passed to a
function having the argument as const or stored in the const "ci_type"
field of a config_item structure.

Done using Coccinelle.

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
* Changes in v2- Combine all the followup patches and the constification
patches into a series.

 samples/configfs/configfs_sample.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/samples/configfs/configfs_sample.c b/samples/configfs/configfs_sample.c
index 1ea3311..004a4e2 100644
--- a/samples/configfs/configfs_sample.c
+++ b/samples/configfs/configfs_sample.c
@@ -115,7 +115,7 @@ static ssize_t childless_description_show(struct config_item *item, char *page)
 	NULL,
 };
 
-static struct config_item_type childless_type = {
+static const struct config_item_type childless_type = {
 	.ct_attrs	= childless_attrs,
 	.ct_owner	= THIS_MODULE,
 };
@@ -193,7 +193,7 @@ static void simple_child_release(struct config_item *item)
 	.release		= simple_child_release,
 };
 
-static struct config_item_type simple_child_type = {
+static const struct config_item_type simple_child_type = {
 	.ct_item_ops	= &simple_child_item_ops,
 	.ct_attrs	= simple_child_attrs,
 	.ct_owner	= THIS_MODULE,
@@ -261,7 +261,7 @@ static void simple_children_release(struct config_item *item)
 	.make_item	= simple_children_make_item,
 };
 
-static struct config_item_type simple_children_type = {
+static const struct config_item_type simple_children_type = {
 	.ct_item_ops	= &simple_children_item_ops,
 	.ct_group_ops	= &simple_children_group_ops,
 	.ct_attrs	= simple_children_attrs,
@@ -331,7 +331,7 @@ static ssize_t group_children_description_show(struct config_item *item,
 	.make_group	= group_children_make_group,
 };
 
-static struct config_item_type group_children_type = {
+static const struct config_item_type group_children_type = {
 	.ct_group_ops	= &group_children_group_ops,
 	.ct_attrs	= group_children_attrs,
 	.ct_owner	= THIS_MODULE,
-- 
1.9.1
