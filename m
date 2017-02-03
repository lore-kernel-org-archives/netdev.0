From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: [PATCH net-next 3/9] sunvnet: update version and version printing
Date: Fri,  3 Feb 2017 09:42:29 -0800
Message-ID: <1486143755-192532-4-git-send-email-shannon.nelson@oracle.com>
References: <1486143755-192532-1-git-send-email-shannon.nelson@oracle.com>
Cc: sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org,
        Shannon Nelson <shannon.nelson@oracle.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1486143755-192532-1-git-send-email-shannon.nelson@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There have been several changes since the first version of this code, so
we bump the version number.  While we're at it, we can simplify the
version printing a bit and drop a couple lines of code.

Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>
---
 drivers/net/ethernet/sun/sunvnet.c |   14 ++++----------
 1 files changed, 4 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index 38d0e42..883525a 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -38,11 +38,11 @@
 #define VNET_TX_TIMEOUT			(5 * HZ)
 
 #define DRV_MODULE_NAME		"sunvnet"
-#define DRV_MODULE_VERSION	"1.0"
-#define DRV_MODULE_RELDATE	"June 25, 2007"
+#define DRV_MODULE_VERSION	"2.0"
+#define DRV_MODULE_RELDATE	"February 3, 2017"
 
 static char version[] =
-	DRV_MODULE_NAME ".c:v" DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
+	DRV_MODULE_NAME " " DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")";
 MODULE_AUTHOR("David S. Miller (davem@davemloft.net)");
 MODULE_DESCRIPTION("Sun LDOM virtual network driver");
 MODULE_LICENSE("GPL");
@@ -300,11 +300,6 @@ static struct vio_driver_ops vnet_vio_ops = {
 	.handshake_complete	= sunvnet_handshake_complete_common,
 };
 
-static void print_version(void)
-{
-	printk_once(KERN_INFO "%s", version);
-}
-
 const char *remote_macaddr_prop = "remote-mac-address";
 
 static int vnet_port_probe(struct vio_dev *vdev, const struct vio_device_id *id)
@@ -317,8 +312,6 @@ static int vnet_port_probe(struct vio_dev *vdev, const struct vio_device_id *id)
 	int len, i, err, switch_port;
 	u64 node;
 
-	print_version();
-
 	hp = mdesc_grab();
 
 	node = vio_vdev_node(hp, vdev);
@@ -453,6 +446,7 @@ static struct vio_driver vnet_port_driver = {
 
 static int __init vnet_init(void)
 {
+	pr_info("%s\n", version);
 	return vio_register_driver(&vnet_port_driver);
 }
 
-- 
1.7.1
