From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH v2 07/15] usb: gadget: configfs: make
	config_item_type const
Date: Mon, 16 Oct 2017 17:18:46 +0200
Message-ID: <1508167134-6243-8-git-send-email-bhumirks@gmail.com>
References: <1508167134-6243-1-git-send-email-bhumirks@gmail.com>
Cc: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, rjw@rjwysocki.net, lenb@kernel.org,
	alexander.shishkin@linux.intel.com, jic23@kernel.org, knaack.h@gmx.de,
	lars@metafoo.de, pmeerw@pmeerw.net, dledford@redhat.com,
	sean.hefty@intel.com, hal.rosenstock@gmail.com, hch@lst.de,
	sagi@grimberg.me, kishon@ti.com, bhelgaas@google.com,
	nab@linux-iscsi.org, balbi@kernel.org, gregkh@linuxfoundation.org,
	laurent.pinchart@ideasonboard.com, jlbec@evilplan.org,
	ccaulfie@redhat.com, teigland@redhat.com, mfasheh@versity.com,
	linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-iio@vger.kernel.org, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, linux-nvme@lists.infradead.org,
	linux-pci@vger.kernel.org, linux-scsi@vger.kernel.org,
	target-devel@vger.kernel.org, linux-usb@vger.kernel.org,
	cluster-devel@redhat.com, ocfs2-devel@oss.oracle.com,
	linux-fsdevel@vger.kernel.org
Return-path: <cluster-devel-bounces@redhat.com>
In-Reply-To: <1508167134-6243-1-git-send-email-bhumirks@gmail.com>
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

Make config_item_type structures const as they are either passed to a
function having the argument as const or stored in the const "ci_type"
field of a config_item structure.

Done using Coccinelle.

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
* Changes in v2- Combine all the followup patches and the constification
patches into a series.

 drivers/usb/gadget/configfs.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/usb/gadget/configfs.c b/drivers/usb/gadget/configfs.c
index aeb9f3c..9d18b99 100644
--- a/drivers/usb/gadget/configfs.c
+++ b/drivers/usb/gadget/configfs.c
@@ -505,13 +505,13 @@ static ssize_t gadget_config_desc_bmAttributes_store(struct config_item *item,
 	NULL,
 };
 
-static struct config_item_type gadget_config_type = {
+static const struct config_item_type gadget_config_type = {
 	.ct_item_ops	= &gadget_config_item_ops,
 	.ct_attrs	= gadget_config_attrs,
 	.ct_owner	= THIS_MODULE,
 };
 
-static struct config_item_type gadget_root_type = {
+static const struct config_item_type gadget_root_type = {
 	.ct_item_ops	= &gadget_root_item_ops,
 	.ct_attrs	= gadget_root_attrs,
 	.ct_owner	= THIS_MODULE,
@@ -593,7 +593,7 @@ static void function_drop(
 	.drop_item      = &function_drop,
 };
 
-static struct config_item_type functions_type = {
+static const struct config_item_type functions_type = {
 	.ct_group_ops   = &functions_ops,
 	.ct_owner       = THIS_MODULE,
 };
@@ -694,7 +694,7 @@ static void config_desc_drop(
 	.drop_item      = &config_desc_drop,
 };
 
-static struct config_item_type config_desc_type = {
+static const struct config_item_type config_desc_type = {
 	.ct_group_ops   = &config_desc_ops,
 	.ct_owner       = THIS_MODULE,
 };
@@ -1476,7 +1476,7 @@ static void gadgets_drop(struct config_group *group, struct config_item *item)
 	.drop_item      = &gadgets_drop,
 };
 
-static struct config_item_type gadgets_type = {
+static const struct config_item_type gadgets_type = {
 	.ct_group_ops   = &gadgets_ops,
 	.ct_owner       = THIS_MODULE,
 };
-- 
1.9.1
