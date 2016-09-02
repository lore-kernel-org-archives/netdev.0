From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/2] hso: Convert printk to pr_<level>
Date: Fri,  2 Sep 2016 15:58:02 -0700
Message-ID: <0be21b4dc3687c1a3bde135fe1f0bf2410b64b4d.1472856901.git.joe@perches.com>
References: <cover.1472856901.git.joe@perches.com>
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jan Dumon <j.dumon@option.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1472856901.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use a more common logging style

Miscellanea:

o Add pr_fmt to prefix each output message
o Realign arguments

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/usb/hso.c | 21 +++++++++++----------
 1 file changed, 11 insertions(+), 10 deletions(-)

diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index 6c37512..e7b5163 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -50,6 +50,8 @@
  *
  *****************************************************************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/sched.h>
 #include <linux/slab.h>
 #include <linux/init.h>
@@ -638,7 +640,7 @@ static int get_free_serial_index(void)
 	}
 	spin_unlock_irqrestore(&serial_table_lock, flags);
 
-	printk(KERN_ERR "%s: no free serial devices in table\n", __func__);
+	pr_err("%s: no free serial devices in table\n", __func__);
 	return -1;
 }
 
@@ -1102,7 +1104,7 @@ static void _hso_serial_set_termios(struct tty_struct *tty,
 	struct hso_serial *serial = tty->driver_data;
 
 	if (!serial) {
-		printk(KERN_ERR "%s: no tty structures", __func__);
+		pr_err("%s: no tty structures", __func__);
 		return;
 	}
 
@@ -1347,7 +1349,7 @@ static int hso_serial_write(struct tty_struct *tty, const unsigned char *buf,
 
 	/* sanity check */
 	if (serial == NULL) {
-		printk(KERN_ERR "%s: serial is NULL\n", __func__);
+		pr_err("%s: serial is NULL\n", __func__);
 		return -ENODEV;
 	}
 
@@ -1773,7 +1775,7 @@ static int mux_device_request(struct hso_serial *serial, u8 type, u16 port,
 
 	/* Sanity check */
 	if (!serial || !ctrl_urb || !ctrl_req) {
-		printk(KERN_ERR "%s: Wrong arguments\n", __func__);
+		pr_err("%s: Wrong arguments\n", __func__);
 		return -EINVAL;
 	}
 
@@ -3220,7 +3222,7 @@ static int __init hso_init(void)
 	int result;
 
 	/* put it in the log */
-	printk(KERN_INFO "hso: %s\n", version);
+	pr_info("%s\n", version);
 
 	/* Initialise the serial table semaphore and table */
 	spin_lock_init(&serial_table_lock);
@@ -3251,16 +3253,15 @@ static int __init hso_init(void)
 	/* register the tty driver */
 	result = tty_register_driver(tty_drv);
 	if (result) {
-		printk(KERN_ERR "%s - tty_register_driver failed(%d)\n",
-			__func__, result);
+		pr_err("%s - tty_register_driver failed(%d)\n",
+		       __func__, result);
 		goto err_free_tty;
 	}
 
 	/* register this module as an usb driver */
 	result = usb_register(&hso_driver);
 	if (result) {
-		printk(KERN_ERR "Could not register hso driver? error: %d\n",
-			result);
+		pr_err("Could not register hso driver - error: %d\n", result);
 		goto err_unreg_tty;
 	}
 
@@ -3275,7 +3276,7 @@ err_free_tty:
 
 static void __exit hso_exit(void)
 {
-	printk(KERN_INFO "hso: unloaded\n");
+	pr_info("unloaded\n");
 
 	tty_unregister_driver(tty_drv);
 	put_tty_driver(tty_drv);
-- 
2.10.0.rc2.1.g053435c
