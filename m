From: domen@coderock.org
Subject: [patch 2/2] net/orinoco_tmd: replace schedule_timeout() with ssleep()
Date: Sun, 06 Mar 2005 23:21:43 +0100
Message-ID: <20050306222143.A91211EFA4@trashy.coderock.org>
Cc: hermes@gibson.dropbear.id.au, netdev@oss.sgi.com, domen@coderock.org,
        nacc@us.ibm.com, janitor@sternwelten.at
To: proski@gnu.org
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org





Use ssleep() instead of schedule_timeout()
to guarantee the task delays as expected.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>
Signed-off-by: Domen Puncer <domen@coderock.org>
---


 kj-domen/drivers/net/wireless/orinoco_tmd.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff -puN drivers/net/wireless/orinoco_tmd.c~ssleep-drivers_net_wireless_orinoco_tmd drivers/net/wireless/orinoco_tmd.c
--- kj/drivers/net/wireless/orinoco_tmd.c~ssleep-drivers_net_wireless_orinoco_tmd	2005-03-05 16:09:50.000000000 +0100
+++ kj-domen/drivers/net/wireless/orinoco_tmd.c	2005-03-05 16:09:50.000000000 +0100
@@ -72,6 +72,7 @@
 #include <linux/list.h>
 #include <linux/pci.h>
 #include <linux/fcntl.h>
+#include <linux/delay.h>
 
 #include <pcmcia/cisreg.h>
 
@@ -218,8 +219,7 @@ static int __init orinoco_tmd_init(void)
 static void __exit orinoco_tmd_exit(void)
 {
 	pci_unregister_driver(&orinoco_tmd_driver);
-	current->state = TASK_UNINTERRUPTIBLE;
-	schedule_timeout(HZ);
+	ssleep(1);
 }
 
 module_init(orinoco_tmd_init);
_
