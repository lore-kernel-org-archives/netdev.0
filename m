From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: [PATCH net-next 8/9] ldmvsw: update and simplify version string
Date: Fri,  3 Feb 2017 09:42:34 -0800
Message-ID: <1486143755-192532-9-git-send-email-shannon.nelson@oracle.com>
References: <1486143755-192532-1-git-send-email-shannon.nelson@oracle.com>
Cc: sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org,
        Shannon Nelson <shannon.nelson@oracle.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1486143755-192532-1-git-send-email-shannon.nelson@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

New version and simplify the print code.

Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>
---
 drivers/net/ethernet/sun/ldmvsw.c |   14 ++++----------
 1 files changed, 4 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/sun/ldmvsw.c b/drivers/net/ethernet/sun/ldmvsw.c
index 7c5dab4..552c0a9 100644
--- a/drivers/net/ethernet/sun/ldmvsw.c
+++ b/drivers/net/ethernet/sun/ldmvsw.c
@@ -42,11 +42,11 @@
 static u8 vsw_port_hwaddr[ETH_ALEN] = {0xFE, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF};
 
 #define DRV_MODULE_NAME		"ldmvsw"
-#define DRV_MODULE_VERSION	"1.0"
-#define DRV_MODULE_RELDATE	"Jan 15, 2016"
+#define DRV_MODULE_VERSION	"1.1"
+#define DRV_MODULE_RELDATE	"February 3, 2017"
 
 static char version[] =
-	DRV_MODULE_NAME ".c:v" DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
+	DRV_MODULE_NAME " " DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")";
 MODULE_AUTHOR("Oracle");
 MODULE_DESCRIPTION("Sun4v LDOM Virtual Switch Driver");
 MODULE_LICENSE("GPL");
@@ -320,11 +320,6 @@ static struct vio_driver_ops vsw_vio_ops = {
 	.handshake_complete	= sunvnet_handshake_complete_common,
 };
 
-static void print_version(void)
-{
-	printk_once(KERN_INFO "%s", version);
-}
-
 static const char *remote_macaddr_prop = "remote-mac-address";
 static const char *id_prop = "id";
 
@@ -341,8 +336,6 @@ static int vsw_port_probe(struct vio_dev *vdev, const struct vio_device_id *id)
 	u64 handle;
 	u64 node;
 
-	print_version();
-
 	hp = mdesc_grab();
 
 	node = vio_vdev_node(hp, vdev);
@@ -527,6 +520,7 @@ static struct vio_driver vsw_port_driver = {
 
 static int __init vsw_init(void)
 {
+	pr_info("%s\n", version);
 	return vio_register_driver(&vsw_port_driver);
 }
 
-- 
1.7.1
