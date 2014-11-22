From: Jeremiah Mahler <jmmahler@gmail.com>
Subject: [PATCH] can: eliminate banner[] variable and switch to pr_info()
Date: Fri, 21 Nov 2014 23:42:35 -0800
Message-ID: <1416642155-31816-1-git-send-email-jmmahler@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jeremiah Mahler <jmmahler@gmail.com>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Several CAN modules use a design pattern with a banner[] variable at the
top which defines a string that is used once during init to print the
banner.  The string is also embedded with KERN_INFO which makes it
printk() specific.

Improve the code by eliminating the banner[] variable and moving the
string to where it is printed.  Then switch from printk(KERN_INFO to
pr_info() for the lines that were changed.

Signed-off-by: Jeremiah Mahler <jmmahler@gmail.com>
---
 net/can/af_can.c | 5 +----
 net/can/bcm.c    | 4 +---
 net/can/raw.c    | 4 +---
 3 files changed, 3 insertions(+), 10 deletions(-)

diff --git a/net/can/af_can.c b/net/can/af_can.c
index ce82337..ac05be1 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -64,9 +64,6 @@
 
 #include "af_can.h"
 
-static __initconst const char banner[] = KERN_INFO
-	"can: controller area network core (" CAN_VERSION_STRING ")\n";
-
 MODULE_DESCRIPTION("Controller Area Network PF_CAN core");
 MODULE_LICENSE("Dual BSD/GPL");
 MODULE_AUTHOR("Urs Thuermann <urs.thuermann@volkswagen.de>, "
@@ -896,7 +893,7 @@ static __init int can_init(void)
 		     offsetof(struct can_frame, data) !=
 		     offsetof(struct canfd_frame, data));
 
-	printk(banner);
+	pr_info("can: controller area network core (" CAN_VERSION_STRING ")\n");
 
 	memset(&can_rx_alldev_list, 0, sizeof(can_rx_alldev_list));
 
diff --git a/net/can/bcm.c b/net/can/bcm.c
index dcb75c0..9aa3f76 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -78,8 +78,6 @@
 		     (CAN_SFF_MASK | CAN_EFF_FLAG | CAN_RTR_FLAG))
 
 #define CAN_BCM_VERSION CAN_VERSION
-static __initconst const char banner[] = KERN_INFO
-	"can: broadcast manager protocol (rev " CAN_BCM_VERSION " t)\n";
 
 MODULE_DESCRIPTION("PF_CAN broadcast manager protocol");
 MODULE_LICENSE("Dual BSD/GPL");
@@ -1615,7 +1613,7 @@ static int __init bcm_module_init(void)
 {
 	int err;
 
-	printk(banner);
+	pr_info("can: broadcast manager protocol (rev " CAN_BCM_VERSION " t)\n");
 
 	err = can_proto_register(&bcm_can_proto);
 	if (err < 0) {
diff --git a/net/can/raw.c b/net/can/raw.c
index 081e81f..e3250e2 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -56,8 +56,6 @@
 #include <net/net_namespace.h>
 
 #define CAN_RAW_VERSION CAN_VERSION
-static __initconst const char banner[] =
-	KERN_INFO "can: raw protocol (rev " CAN_RAW_VERSION ")\n";
 
 MODULE_DESCRIPTION("PF_CAN raw protocol");
 MODULE_LICENSE("Dual BSD/GPL");
@@ -810,7 +808,7 @@ static __init int raw_module_init(void)
 {
 	int err;
 
-	printk(banner);
+	pr_info("can: raw protocol (rev " CAN_RAW_VERSION ")\n");
 
 	err = can_proto_register(&raw_can_proto);
 	if (err < 0)
-- 
2.1.3

