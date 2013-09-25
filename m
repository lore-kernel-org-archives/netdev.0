From: Joe Perches <joe@perches.com>
Subject: [PATCH 03/11] wimax: Remove extern from function prototypes
Date: Wed, 25 Sep 2013 12:37:21 -0700
Message-ID: <8bedb968b246c5bf5009f8f083451506a496d6e8.1380137609.git.joe@perches.com>
References: <cover.1380137609.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>,
	linux-wimax@intel.com, wimax@linuxwimax.org,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1380137609.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are a mix of function prototypes with and without extern
in the kernel sources.  Standardize on not using extern for
function prototypes.

Function prototypes don't need to be written with extern.
extern is assumed by the compiler.  Its use is as unnecessary as
using auto to declare automatic/local variables in a block.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wimax/i2400m/i2400m-usb.h |  27 ++++----
 drivers/net/wimax/i2400m/i2400m.h     | 117 +++++++++++++++++-----------------
 2 files changed, 70 insertions(+), 74 deletions(-)

diff --git a/drivers/net/wimax/i2400m/i2400m-usb.h b/drivers/net/wimax/i2400m/i2400m-usb.h
index 9f1e947..649ecad 100644
--- a/drivers/net/wimax/i2400m/i2400m-usb.h
+++ b/drivers/net/wimax/i2400m/i2400m-usb.h
@@ -256,21 +256,20 @@ void i2400mu_init(struct i2400mu *i2400mu)
 	i2400mu->rx_size_auto_shrink = 1;
 }
 
-extern int i2400mu_notification_setup(struct i2400mu *);
-extern void i2400mu_notification_release(struct i2400mu *);
+int i2400mu_notification_setup(struct i2400mu *);
+void i2400mu_notification_release(struct i2400mu *);
 
-extern int i2400mu_rx_setup(struct i2400mu *);
-extern void i2400mu_rx_release(struct i2400mu *);
-extern void i2400mu_rx_kick(struct i2400mu *);
+int i2400mu_rx_setup(struct i2400mu *);
+void i2400mu_rx_release(struct i2400mu *);
+void i2400mu_rx_kick(struct i2400mu *);
 
-extern int i2400mu_tx_setup(struct i2400mu *);
-extern void i2400mu_tx_release(struct i2400mu *);
-extern void i2400mu_bus_tx_kick(struct i2400m *);
+int i2400mu_tx_setup(struct i2400mu *);
+void i2400mu_tx_release(struct i2400mu *);
+void i2400mu_bus_tx_kick(struct i2400m *);
 
-extern ssize_t i2400mu_bus_bm_cmd_send(struct i2400m *,
-				       const struct i2400m_bootrom_header *,
-				       size_t, int);
-extern ssize_t i2400mu_bus_bm_wait_for_ack(struct i2400m *,
-					   struct i2400m_bootrom_header *,
-					   size_t);
+ssize_t i2400mu_bus_bm_cmd_send(struct i2400m *,
+				const struct i2400m_bootrom_header *, size_t,
+				int);
+ssize_t i2400mu_bus_bm_wait_for_ack(struct i2400m *,
+				    struct i2400m_bootrom_header *, size_t);
 #endif /* #ifndef __I2400M_USB_H__ */
diff --git a/drivers/net/wimax/i2400m/i2400m.h b/drivers/net/wimax/i2400m/i2400m.h
index 79c6505..5a34e72 100644
--- a/drivers/net/wimax/i2400m/i2400m.h
+++ b/drivers/net/wimax/i2400m/i2400m.h
@@ -710,18 +710,18 @@ enum i2400m_bri {
 	I2400M_BRI_MAC_REINIT = 1 << 3,
 };
 
-extern void i2400m_bm_cmd_prepare(struct i2400m_bootrom_header *);
-extern int i2400m_dev_bootstrap(struct i2400m *, enum i2400m_bri);
-extern int i2400m_read_mac_addr(struct i2400m *);
-extern int i2400m_bootrom_init(struct i2400m *, enum i2400m_bri);
-extern int i2400m_is_boot_barker(struct i2400m *, const void *, size_t);
+void i2400m_bm_cmd_prepare(struct i2400m_bootrom_header *);
+int i2400m_dev_bootstrap(struct i2400m *, enum i2400m_bri);
+int i2400m_read_mac_addr(struct i2400m *);
+int i2400m_bootrom_init(struct i2400m *, enum i2400m_bri);
+int i2400m_is_boot_barker(struct i2400m *, const void *, size_t);
 static inline
 int i2400m_is_d2h_barker(const void *buf)
 {
 	const __le32 *barker = buf;
 	return le32_to_cpu(*barker) == I2400M_D2H_MSG_BARKER;
 }
-extern void i2400m_unknown_barker(struct i2400m *, const void *, size_t);
+void i2400m_unknown_barker(struct i2400m *, const void *, size_t);
 
 /* Make/grok boot-rom header commands */
 
@@ -789,32 +789,31 @@ unsigned i2400m_brh_get_signature(const struct i2400m_bootrom_header *hdr)
 /*
  * Driver / device setup and internal functions
  */
-extern void i2400m_init(struct i2400m *);
-extern int i2400m_reset(struct i2400m *, enum i2400m_reset_type);
-extern void i2400m_netdev_setup(struct net_device *net_dev);
-extern int i2400m_sysfs_setup(struct device_driver *);
-extern void i2400m_sysfs_release(struct device_driver *);
-extern int i2400m_tx_setup(struct i2400m *);
-extern void i2400m_wake_tx_work(struct work_struct *);
-extern void i2400m_tx_release(struct i2400m *);
-
-extern int i2400m_rx_setup(struct i2400m *);
-extern void i2400m_rx_release(struct i2400m *);
-
-extern void i2400m_fw_cache(struct i2400m *);
-extern void i2400m_fw_uncache(struct i2400m *);
-
-extern void i2400m_net_rx(struct i2400m *, struct sk_buff *, unsigned,
-			  const void *, int);
-extern void i2400m_net_erx(struct i2400m *, struct sk_buff *,
-			   enum i2400m_cs);
-extern void i2400m_net_wake_stop(struct i2400m *);
+void i2400m_init(struct i2400m *);
+int i2400m_reset(struct i2400m *, enum i2400m_reset_type);
+void i2400m_netdev_setup(struct net_device *net_dev);
+int i2400m_sysfs_setup(struct device_driver *);
+void i2400m_sysfs_release(struct device_driver *);
+int i2400m_tx_setup(struct i2400m *);
+void i2400m_wake_tx_work(struct work_struct *);
+void i2400m_tx_release(struct i2400m *);
+
+int i2400m_rx_setup(struct i2400m *);
+void i2400m_rx_release(struct i2400m *);
+
+void i2400m_fw_cache(struct i2400m *);
+void i2400m_fw_uncache(struct i2400m *);
+
+void i2400m_net_rx(struct i2400m *, struct sk_buff *, unsigned, const void *,
+		   int);
+void i2400m_net_erx(struct i2400m *, struct sk_buff *, enum i2400m_cs);
+void i2400m_net_wake_stop(struct i2400m *);
 enum i2400m_pt;
-extern int i2400m_tx(struct i2400m *, const void *, size_t, enum i2400m_pt);
+int i2400m_tx(struct i2400m *, const void *, size_t, enum i2400m_pt);
 
 #ifdef CONFIG_DEBUG_FS
-extern int i2400m_debugfs_add(struct i2400m *);
-extern void i2400m_debugfs_rm(struct i2400m *);
+int i2400m_debugfs_add(struct i2400m *);
+void i2400m_debugfs_rm(struct i2400m *);
 #else
 static inline int i2400m_debugfs_add(struct i2400m *i2400m)
 {
@@ -824,8 +823,8 @@ static inline void i2400m_debugfs_rm(struct i2400m *i2400m) {}
 #endif
 
 /* Initialize/shutdown the device */
-extern int i2400m_dev_initialize(struct i2400m *);
-extern void i2400m_dev_shutdown(struct i2400m *);
+int i2400m_dev_initialize(struct i2400m *);
+void i2400m_dev_shutdown(struct i2400m *);
 
 extern struct attribute_group i2400m_dev_attr_group;
 
@@ -873,21 +872,21 @@ void i2400m_put(struct i2400m *i2400m)
 	dev_put(i2400m->wimax_dev.net_dev);
 }
 
-extern int i2400m_dev_reset_handle(struct i2400m *, const char *);
-extern int i2400m_pre_reset(struct i2400m *);
-extern int i2400m_post_reset(struct i2400m *);
-extern void i2400m_error_recovery(struct i2400m *);
+int i2400m_dev_reset_handle(struct i2400m *, const char *);
+int i2400m_pre_reset(struct i2400m *);
+int i2400m_post_reset(struct i2400m *);
+void i2400m_error_recovery(struct i2400m *);
 
 /*
  * _setup()/_release() are called by the probe/disconnect functions of
  * the bus-specific drivers.
  */
-extern int i2400m_setup(struct i2400m *, enum i2400m_bri bm_flags);
-extern void i2400m_release(struct i2400m *);
+int i2400m_setup(struct i2400m *, enum i2400m_bri bm_flags);
+void i2400m_release(struct i2400m *);
 
-extern int i2400m_rx(struct i2400m *, struct sk_buff *);
-extern struct i2400m_msg_hdr *i2400m_tx_msg_get(struct i2400m *, size_t *);
-extern void i2400m_tx_msg_sent(struct i2400m *);
+int i2400m_rx(struct i2400m *, struct sk_buff *);
+struct i2400m_msg_hdr *i2400m_tx_msg_get(struct i2400m *, size_t *);
+void i2400m_tx_msg_sent(struct i2400m *);
 
 
 /*
@@ -900,20 +899,19 @@ struct device *i2400m_dev(struct i2400m *i2400m)
 	return i2400m->wimax_dev.net_dev->dev.parent;
 }
 
-extern int i2400m_msg_check_status(const struct i2400m_l3l4_hdr *,
-				   char *, size_t);
-extern int i2400m_msg_size_check(struct i2400m *,
-				 const struct i2400m_l3l4_hdr *, size_t);
-extern struct sk_buff *i2400m_msg_to_dev(struct i2400m *, const void *, size_t);
-extern void i2400m_msg_to_dev_cancel_wait(struct i2400m *, int);
-extern void i2400m_report_hook(struct i2400m *,
-			       const struct i2400m_l3l4_hdr *, size_t);
-extern void i2400m_report_hook_work(struct work_struct *);
-extern int i2400m_cmd_enter_powersave(struct i2400m *);
-extern int i2400m_cmd_exit_idle(struct i2400m *);
-extern struct sk_buff *i2400m_get_device_info(struct i2400m *);
-extern int i2400m_firmware_check(struct i2400m *);
-extern int i2400m_set_idle_timeout(struct i2400m *, unsigned);
+int i2400m_msg_check_status(const struct i2400m_l3l4_hdr *, char *, size_t);
+int i2400m_msg_size_check(struct i2400m *, const struct i2400m_l3l4_hdr *,
+			  size_t);
+struct sk_buff *i2400m_msg_to_dev(struct i2400m *, const void *, size_t);
+void i2400m_msg_to_dev_cancel_wait(struct i2400m *, int);
+void i2400m_report_hook(struct i2400m *, const struct i2400m_l3l4_hdr *,
+			size_t);
+void i2400m_report_hook_work(struct work_struct *);
+int i2400m_cmd_enter_powersave(struct i2400m *);
+int i2400m_cmd_exit_idle(struct i2400m *);
+struct sk_buff *i2400m_get_device_info(struct i2400m *);
+int i2400m_firmware_check(struct i2400m *);
+int i2400m_set_idle_timeout(struct i2400m *, unsigned);
 
 static inline
 struct usb_endpoint_descriptor *usb_get_epd(struct usb_interface *iface, int ep)
@@ -921,10 +919,9 @@ struct usb_endpoint_descriptor *usb_get_epd(struct usb_interface *iface, int ep)
 	return &iface->cur_altsetting->endpoint[ep].desc;
 }
 
-extern int i2400m_op_rfkill_sw_toggle(struct wimax_dev *,
-				      enum wimax_rf_state);
-extern void i2400m_report_tlv_rf_switches_status(
-	struct i2400m *, const struct i2400m_tlv_rf_switches_status *);
+int i2400m_op_rfkill_sw_toggle(struct wimax_dev *, enum wimax_rf_state);
+void i2400m_report_tlv_rf_switches_status(struct i2400m *,
+					  const struct i2400m_tlv_rf_switches_status *);
 
 /*
  * Helpers for firmware backwards compatibility
@@ -968,8 +965,8 @@ void __i2400m_msleep(unsigned ms)
 
 
 /* module initialization helpers */
-extern int i2400m_barker_db_init(const char *);
-extern void i2400m_barker_db_exit(void);
+int i2400m_barker_db_init(const char *);
+void i2400m_barker_db_exit(void);
 
 
 
-- 
1.8.1.2.459.gbcd45b4.dirty
