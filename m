From: Joe Perches <joe@perches.com>
Subject: [PATCH wireless-next 20/20] zd_usb: Use pr_<level>
Date: Thu, 14 Jun 2012 22:54:00 -0700
Message-ID: <23bc83f167ea60e3192341166fb9f566cd1215d5.1339739416.git.joe@perches.com>
References: <cover.1339739415.git.joe@perches.com>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Daniel Drake <dsd@gentoo.org>, Ulrich Kunitz <kune@deine-taler.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1339739415.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use a more current logging style.

Convert printks to pr_<level>.
Coalesce formats, align arguments.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/zd1211rw/zd_usb.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/zd1211rw/zd_usb.c b/drivers/net/wireless/zd1211rw/zd_usb.c
index af83c43..7acaa1d 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -19,6 +19,8 @@
  * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/firmware.h>
@@ -1551,29 +1553,28 @@ static int __init usb_init(void)
 {
 	int r;
 
-	pr_debug("%s usb_init()\n", driver.name);
+	pr_debug("usb_init()\n");
 
 	zd_workqueue = create_singlethread_workqueue(driver.name);
 	if (zd_workqueue == NULL) {
-		printk(KERN_ERR "%s couldn't create workqueue\n", driver.name);
+		pr_err("couldn't create workqueue\n");
 		return -ENOMEM;
 	}
 
 	r = usb_register(&driver);
 	if (r) {
 		destroy_workqueue(zd_workqueue);
-		printk(KERN_ERR "%s usb_register() failed. Error number %d\n",
-		       driver.name, r);
+		pr_err("usb_register() failed. Error number %d\n", r);
 		return r;
 	}
 
-	pr_debug("%s initialized\n", driver.name);
+	pr_debug("initialized\n");
 	return 0;
 }
 
 static void __exit usb_exit(void)
 {
-	pr_debug("%s usb_exit()\n", driver.name);
+	pr_debug("usb_exit()\n");
 	usb_deregister(&driver);
 	destroy_workqueue(zd_workqueue);
 }
-- 
1.7.8.111.gad25c.dirty
