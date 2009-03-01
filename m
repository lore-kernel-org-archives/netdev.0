From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH] wimax: struct device - replace bus_id with dev_name(),
	dev_set_name()
Date: Sun,  1 Mar 2009 01:42:51 -0800
Message-ID: <1235900574-15319-5-git-send-email-inaky@linux.intel.com>
References: <1235900574-15319-1-git-send-email-inaky@linux.intel.com>
	<1235900574-15319-2-git-send-email-inaky@linux.intel.com>
	<1235900574-15319-3-git-send-email-inaky@linux.intel.com>
	<1235900574-15319-4-git-send-email-inaky@linux.intel.com>
Cc: netdev@vger.kernel.org, Kay Sievers <kay.sievers@vrfy.org>,
	linux-wimax@intel.com
To: wimax@linuxwimax.org
Return-path: <wimax-bounces@linuxwimax.org>
In-Reply-To: <1235900574-15319-4-git-send-email-inaky@linux.intel.com>
List-Unsubscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.moblin.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org

From: Kay Sievers <kay.sievers@vrfy.org>

Cc: inaky.perez-gonzalez@intel.com
Cc: linux-wimax@intel.com
Acked-by: Greg Kroah-Hartman <gregkh@suse.de>
Signed-off-by: Kay Sievers <kay.sievers@vrfy.org>
Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/driver.c    |    2 +-
 drivers/net/wimax/i2400m/usb-notif.c |    2 +-
 include/linux/wimax/debug.h          |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
index f988771..e4f1ce5 100644
--- a/drivers/net/wimax/i2400m/driver.c
+++ b/drivers/net/wimax/i2400m/driver.c
@@ -618,7 +618,7 @@ int i2400m_setup(struct i2400m *i2400m, enum i2400m_bri bm_flags)
 	d_fnstart(3, dev, "(i2400m %p)\n", i2400m);
 
 	snprintf(wimax_dev->name, sizeof(wimax_dev->name),
-		 "i2400m-%s:%s", dev->bus->name, dev->bus_id);
+		 "i2400m-%s:%s", dev->bus->name, dev_name(dev));
 
 	i2400m->bm_cmd_buf = kzalloc(I2400M_BM_CMD_BUF_SIZE, GFP_KERNEL);
 	if (i2400m->bm_cmd_buf == NULL) {
diff --git a/drivers/net/wimax/i2400m/usb-notif.c b/drivers/net/wimax/i2400m/usb-notif.c
index 9702c22..6add27c 100644
--- a/drivers/net/wimax/i2400m/usb-notif.c
+++ b/drivers/net/wimax/i2400m/usb-notif.c
@@ -102,7 +102,7 @@ int i2400mu_notification_grok(struct i2400mu *i2400mu, const void *buf,
 		dev_err(dev, "HW BUG? Unknown/unexpected data in notification "
 			"message (%zu bytes)\n", buf_len);
 		snprintf(prefix, sizeof(prefix), "%s %s: ",
-			 dev_driver_string(dev) , dev->bus_id);
+			 dev_driver_string(dev), dev_name(dev));
 		if (buf_len > 64) {
 			print_hex_dump(KERN_ERR, prefix, DUMP_PREFIX_OFFSET,
 				       8, 4, buf, 64, 0);
diff --git a/include/linux/wimax/debug.h b/include/linux/wimax/debug.h
index ba0c493..c703e03 100644
--- a/include/linux/wimax/debug.h
+++ b/include/linux/wimax/debug.h
@@ -178,7 +178,7 @@ void __d_head(char *head, size_t head_size,
 		WARN_ON(1);
 	} else
 		snprintf(head, head_size, "%s %s: ",
-			 dev_driver_string(dev), dev->bus_id);
+			 dev_driver_string(dev), dev_name(dev));
 }
 
 
-- 
1.5.6.5
