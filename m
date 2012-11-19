From: Bill Pemberton <wfp5p@virginia.edu>
Subject: [PATCH 086/493] net: remove use of __devexit_p
Date: Mon, 19 Nov 2012 13:20:35 -0500
Message-ID: <1353349642-3677-86-git-send-email-wfp5p@virginia.edu>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xensource.com, "Michael S. Tsirkin" <mst@redhat.com>,
	"VMware, Inc." <pv-drivers@vmware.com>, netdev@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	Shreyas Bhatewara <sbhatewara@vmware.com>,
	virtualization@lists.linux-foundation.org,
	Francois Romieu <romieu@fr.zoreil.com>
To: gregkh@linuxfoundation.org
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

CONFIG_HOTPLUG is going away as an option so __devexit_p is no longer
needed.

Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
Cc: Rusty Russell <rusty@rustcorp.com.au> 
Cc: "Michael S. Tsirkin" <mst@redhat.com> 
Cc: Shreyas Bhatewara <sbhatewara@vmware.com> 
Cc: "VMware, Inc." <pv-drivers@vmware.com> 
Cc: Francois Romieu <romieu@fr.zoreil.com> 
Cc: virtualization@lists.linux-foundation.org 
Cc: netdev@vger.kernel.org 
Cc: xen-devel@lists.xensource.com 
---
 drivers/net/virtio_net.c          | 2 +-
 drivers/net/vmxnet3/vmxnet3_drv.c | 2 +-
 drivers/net/wan/dscc4.c           | 2 +-
 drivers/net/wan/farsync.c         | 2 +-
 drivers/net/wan/lmc/lmc_main.c    | 2 +-
 drivers/net/xen-netfront.c        | 2 +-
 6 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 97f4ff8..b0c1630 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1285,7 +1285,7 @@ static struct virtio_driver virtio_net_driver = {
 	.driver.owner =	THIS_MODULE,
 	.id_table =	id_table,
 	.probe =	virtnet_probe,
-	.remove =	__devexit_p(virtnet_remove),
+	.remove =	virtnet_remove,
 	.config_changed = virtnet_config_changed,
 #ifdef CONFIG_PM
 	.freeze =	virtnet_freeze,
diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 7e9622f..aa1bde8 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -3302,7 +3302,7 @@ static struct pci_driver vmxnet3_driver = {
 	.name		= vmxnet3_driver_name,
 	.id_table	= vmxnet3_pciid_table,
 	.probe		= vmxnet3_probe_device,
-	.remove		= __devexit_p(vmxnet3_remove_device),
+	.remove		= vmxnet3_remove_device,
 #ifdef CONFIG_PM
 	.driver.pm	= &vmxnet3_pm_ops,
 #endif
diff --git a/drivers/net/wan/dscc4.c b/drivers/net/wan/dscc4.c
index ef36caf..2eddbbf 100644
--- a/drivers/net/wan/dscc4.c
+++ b/drivers/net/wan/dscc4.c
@@ -2053,7 +2053,7 @@ static struct pci_driver dscc4_driver = {
 	.name		= DRV_NAME,
 	.id_table	= dscc4_pci_tbl,
 	.probe		= dscc4_init_one,
-	.remove		= __devexit_p(dscc4_remove_one),
+	.remove		= dscc4_remove_one,
 };
 
 module_pci_driver(dscc4_driver);
diff --git a/drivers/net/wan/farsync.c b/drivers/net/wan/farsync.c
index b627132..0397544 100644
--- a/drivers/net/wan/farsync.c
+++ b/drivers/net/wan/farsync.c
@@ -2652,7 +2652,7 @@ static struct pci_driver fst_driver = {
         .name		= FST_NAME,
         .id_table	= fst_pci_dev_id,
         .probe		= fst_add_one,
-        .remove	= __devexit_p(fst_remove_one),
+	.remove		= fst_remove_one,
         .suspend	= NULL,
         .resume	= NULL,
 };
diff --git a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_main.c
index f5d533a..358e25f 100644
--- a/drivers/net/wan/lmc/lmc_main.c
+++ b/drivers/net/wan/lmc/lmc_main.c
@@ -1733,7 +1733,7 @@ static struct pci_driver lmc_driver = {
 	.name		= "lmc",
 	.id_table	= lmc_pci_tbl,
 	.probe		= lmc_init_one,
-	.remove		= __devexit_p(lmc_remove_one),
+	.remove		= lmc_remove_one,
 };
 
 module_pci_driver(lmc_driver);
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index caa0110..3c3b93e 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1934,7 +1934,7 @@ static int __devexit xennet_remove(struct xenbus_device *dev)
 
 static DEFINE_XENBUS_DRIVER(netfront, ,
 	.probe = netfront_probe,
-	.remove = __devexit_p(xennet_remove),
+	.remove = xennet_remove,
 	.resume = netfront_resume,
 	.otherend_changed = netback_changed,
 );
-- 
1.8.0
