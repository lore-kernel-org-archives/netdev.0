From: janitor@sternwelten.at
Subject: [patch 18/18]  net/orinoco_plx: replace 	schedule_timeout() with ssleep()
Date: Sun, 31 Oct 2004 00:43:17 +0200
Message-ID: <E1CO1wL-0002nU-B8@sputnik>
Cc: netdev@oss.sgi.com, janitor@sternwelten.at, nacc@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




Any comments would be appreciated.

Description: Use ssleep() instead of schedule_timeout()
to guarantee the task delays as expected.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>

---

 linux-2.6.10-rc1-max/drivers/net/wireless/orinoco_plx.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff -puN drivers/net/wireless/orinoco_plx.c~ssleep-drivers_net_wireless_orinoco_plx drivers/net/wireless/orinoco_plx.c
--- linux-2.6.10-rc1/drivers/net/wireless/orinoco_plx.c~ssleep-drivers_net_wireless_orinoco_plx	2004-10-24 17:06:13.000000000 +0200
+++ linux-2.6.10-rc1-max/drivers/net/wireless/orinoco_plx.c	2004-10-24 17:06:13.000000000 +0200
@@ -136,6 +136,7 @@
 #include <linux/list.h>
 #include <linux/pci.h>
 #include <linux/fcntl.h>
+#include <linux/delay.h>
 
 #include <pcmcia/cisreg.h>
 
@@ -352,8 +353,7 @@ static int __init orinoco_plx_init(void)
 static void __exit orinoco_plx_exit(void)
 {
 	pci_unregister_driver(&orinoco_plx_driver);
-	current->state = TASK_UNINTERRUPTIBLE;
-	schedule_timeout(HZ);
+	ssleep(1);
 }
 
 module_init(orinoco_plx_init);
_
