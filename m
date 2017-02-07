From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: [PATCH v2 net-next 8/9] ldmvsw: update and simplify version string
Date: Tue,  7 Feb 2017 14:13:01 -0800
Message-ID: <1486505582-76823-9-git-send-email-shannon.nelson@oracle.com>
References: <1486505582-76823-1-git-send-email-shannon.nelson@oracle.com>
Cc: sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org,
        Shannon Nelson <shannon.nelson@oracle.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1486505582-76823-1-git-send-email-shannon.nelson@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

New version and simplify the print code.

Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>
---
 drivers/net/ethernet/sun/ldmvsw.c |   14 ++++----------
 1 files changed, 4 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/sun/ldmvsw.c b/drivers/net/ethernet/sun/ldmvsw.c
index 3999fb7..3ef5c08 100644
--- a/drivers/net/ethernet/sun/ldmvsw.c
+++ b/drivers/net/ethernet/sun/ldmvsw.c
@@ -41,11 +41,11 @@
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
@@ -322,11 +322,6 @@ static void vsw_poll_controller(struct net_device *dev)
 	.handshake_complete	= sunvnet_handshake_complete_common,
 };
 
-static void print_version(void)
-{
-	printk_once(KERN_INFO "%s", version);
-}
-
 static const char *remote_macaddr_prop = "remote-mac-address";
 static const char *id_prop = "id";
 
@@ -342,8 +337,6 @@ static int vsw_port_probe(struct vio_dev *vdev, const struct vio_device_id *id)
 	const u64 *port_id;
 	u64 handle;
 
-	print_version();
-
 	hp = mdesc_grab();
 
 	rmac = mdesc_get_property(hp, vdev->mp, remote_macaddr_prop, &len);
@@ -520,6 +513,7 @@ static void vsw_cleanup(void)
 
 static int __init vsw_init(void)
 {
+	pr_info("%s\n", version);
 	return vio_register_driver(&vsw_port_driver);
 }
 
-- 
1.7.1
