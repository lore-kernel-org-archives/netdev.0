From: Joe Perches <joe@perches.com>
Subject: [PATCH wireless-next 19/20] wl3501_cs: Use pr_<level>
Date: Thu, 14 Jun 2012 22:53:59 -0700
Message-ID: <1993e467eb3e9774d18c011667ea92a4f55832c7.1339739416.git.joe@perches.com>
References: <cover.1339739415.git.joe@perches.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1339739415.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use a more current logging style.

Convert printks to pr_<level>.
Coalesce formats, align arguments.
Add newline terminations to pr_debug uses.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/wl3501_cs.c |   80 ++++++++++++++++++--------------------
 1 files changed, 38 insertions(+), 42 deletions(-)

diff --git a/drivers/net/wireless/wl3501_cs.c b/drivers/net/wireless/wl3501_cs.c
index 00f6e69..a7dac1a 100644
--- a/drivers/net/wireless/wl3501_cs.c
+++ b/drivers/net/wireless/wl3501_cs.c
@@ -27,6 +27,8 @@
  * with a SMP machine (dual pentium 100), using pktgen, 432 pps (pkt_size = 60)
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/delay.h>
 #include <linux/types.h>
 #include <linux/init.h>
@@ -431,9 +433,9 @@ static int wl3501_pwr_mgmt(struct wl3501_card *this, int suspend)
 			spin_unlock_irqrestore(&this->lock, flags);
 			rc = wait_event_interruptible(this->wait,
 				this->sig_pwr_mgmt_confirm.status != 255);
-			printk(KERN_INFO "%s: %s status=%d\n", __func__,
-			       suspend ? "suspend" : "resume",
-			       this->sig_pwr_mgmt_confirm.status);
+			pr_info("%s: %s status=%d\n",
+				__func__, suspend ? "suspend" : "resume",
+				this->sig_pwr_mgmt_confirm.status);
 			goto out;
 		}
 	}
@@ -650,10 +652,10 @@ static void wl3501_mgmt_scan_confirm(struct wl3501_card *this, u16 addr)
 	int matchflag = 0;
 	struct wl3501_scan_confirm sig;
 
-	pr_debug("entry");
+	pr_debug("entry\n");
 	wl3501_get_from_wla(this, addr, &sig, sizeof(sig));
 	if (sig.status == WL3501_STATUS_SUCCESS) {
-		pr_debug("success");
+		pr_debug("success\n");
 		if ((this->net_type == IW_MODE_INFRA &&
 		     (sig.cap_info & WL3501_MGMT_CAPABILITY_ESS)) ||
 		    (this->net_type == IW_MODE_ADHOC &&
@@ -688,7 +690,7 @@ static void wl3501_mgmt_scan_confirm(struct wl3501_card *this, u16 addr)
 			}
 		}
 	} else if (sig.status == WL3501_STATUS_TIMEOUT) {
-		pr_debug("timeout");
+		pr_debug("timeout\n");
 		this->join_sta_bss = 0;
 		for (i = this->join_sta_bss; i < this->bss_cnt; i++)
 			if (!wl3501_mgmt_join(this, i))
@@ -822,8 +824,8 @@ static void wl3501_online(struct net_device *dev)
 {
 	struct wl3501_card *this = netdev_priv(dev);
 
-	printk(KERN_INFO "%s: Wireless LAN online. BSSID: %pM\n",
-	       dev->name, this->bssid);
+	pr_info("%s: Wireless LAN online. BSSID: %pM\n",
+		dev->name, this->bssid);
 	netif_wake_queue(dev);
 }
 
@@ -845,7 +847,7 @@ static int wl3501_mgmt_auth(struct wl3501_card *this)
 		.timeout = 1000,
 	};
 
-	pr_debug("entry");
+	pr_debug("entry\n");
 	memcpy(sig.mac_addr, this->bssid, ETH_ALEN);
 	return wl3501_esbq_exec(this, &sig, sizeof(sig));
 }
@@ -859,7 +861,7 @@ static int wl3501_mgmt_association(struct wl3501_card *this)
 		.cap_info	 = this->cap_info,
 	};
 
-	pr_debug("entry");
+	pr_debug("entry\n");
 	memcpy(sig.mac_addr, this->bssid, ETH_ALEN);
 	return wl3501_esbq_exec(this, &sig, sizeof(sig));
 }
@@ -869,7 +871,7 @@ static void wl3501_mgmt_join_confirm(struct net_device *dev, u16 addr)
 	struct wl3501_card *this = netdev_priv(dev);
 	struct wl3501_join_confirm sig;
 
-	pr_debug("entry");
+	pr_debug("entry\n");
 	wl3501_get_from_wla(this, addr, &sig, sizeof(sig));
 	if (sig.status == WL3501_STATUS_SUCCESS) {
 		if (this->net_type == IW_MODE_INFRA) {
@@ -916,7 +918,7 @@ static inline void wl3501_alarm_interrupt(struct net_device *dev,
 					  struct wl3501_card *this)
 {
 	if (this->net_type == IW_MODE_INFRA) {
-		printk(KERN_INFO "Wireless LAN offline\n");
+		pr_info("Wireless LAN offline\n");
 		netif_stop_queue(dev);
 		wl3501_mgmt_resync(this);
 	}
@@ -928,7 +930,7 @@ static inline void wl3501_md_confirm_interrupt(struct net_device *dev,
 {
 	struct wl3501_md_confirm sig;
 
-	pr_debug("entry");
+	pr_debug("entry\n");
 	wl3501_get_from_wla(this, addr, &sig, sizeof(sig));
 	wl3501_free_tx_buffer(this, sig.data);
 	if (netif_queue_stopped(dev))
@@ -956,7 +958,7 @@ static inline void wl3501_md_ind_interrupt(struct net_device *dev,
 			    &addr4, sizeof(addr4));
 	if (!(addr4[0] == 0xAA && addr4[1] == 0xAA &&
 	      addr4[2] == 0x03 && addr4[4] == 0x00)) {
-		printk(KERN_INFO "Insupported packet type!\n");
+		pr_info("Insupported packet type!\n");
 		return;
 	}
 	pkt_len = sig.size + 12 - 24 - 4 - 6;
@@ -964,8 +966,8 @@ static inline void wl3501_md_ind_interrupt(struct net_device *dev,
 	skb = dev_alloc_skb(pkt_len + 5);
 
 	if (!skb) {
-		printk(KERN_WARNING "%s: Can't alloc a sk_buff of size %d.\n",
-		       dev->name, pkt_len);
+		pr_warn("%s: Can't alloc a sk_buff of size %d\n",
+			dev->name, pkt_len);
 		dev->stats.rx_dropped++;
 	} else {
 		skb->dev = dev;
@@ -983,7 +985,7 @@ static inline void wl3501_md_ind_interrupt(struct net_device *dev,
 static inline void wl3501_get_confirm_interrupt(struct wl3501_card *this,
 						u16 addr, void *sig, int size)
 {
-	pr_debug("entry");
+	pr_debug("entry\n");
 	wl3501_get_from_wla(this, addr, &this->sig_get_confirm,
 			    sizeof(this->sig_get_confirm));
 	wake_up(&this->wait);
@@ -995,7 +997,7 @@ static inline void wl3501_start_confirm_interrupt(struct net_device *dev,
 {
 	struct wl3501_start_confirm sig;
 
-	pr_debug("entry");
+	pr_debug("entry\n");
 	wl3501_get_from_wla(this, addr, &sig, sizeof(sig));
 	if (sig.status == WL3501_STATUS_SUCCESS)
 		netif_wake_queue(dev);
@@ -1007,7 +1009,7 @@ static inline void wl3501_assoc_confirm_interrupt(struct net_device *dev,
 	struct wl3501_card *this = netdev_priv(dev);
 	struct wl3501_assoc_confirm sig;
 
-	pr_debug("entry");
+	pr_debug("entry\n");
 	wl3501_get_from_wla(this, addr, &sig, sizeof(sig));
 
 	if (sig.status == WL3501_STATUS_SUCCESS)
@@ -1019,7 +1021,7 @@ static inline void wl3501_auth_confirm_interrupt(struct wl3501_card *this,
 {
 	struct wl3501_auth_confirm sig;
 
-	pr_debug("entry");
+	pr_debug("entry\n");
 	wl3501_get_from_wla(this, addr, &sig, sizeof(sig));
 
 	if (sig.status == WL3501_STATUS_SUCCESS)
@@ -1035,7 +1037,7 @@ static inline void wl3501_rx_interrupt(struct net_device *dev)
 	u8 sig_id;
 	struct wl3501_card *this = netdev_priv(dev);
 
-	pr_debug("entry");
+	pr_debug("entry\n");
 loop:
 	morepkts = 0;
 	if (!wl3501_esbq_confirm(this))
@@ -1158,7 +1160,7 @@ static int wl3501_reset_board(struct wl3501_card *this)
 		}
 		WL3501_NOPLOOP(10);
 	}
-	printk(KERN_WARNING "%s: failed to reset the board!\n", __func__);
+	pr_warn("%s: failed to reset the board!\n", __func__);
 	rc = -ENODEV;
 out:
 	return rc;
@@ -1209,7 +1211,7 @@ static int wl3501_init_firmware(struct wl3501_card *this)
 out:
 	return rc;
 fail:
-	printk(KERN_WARNING "%s: failed!\n", __func__);
+	pr_warn("%s: failed!\n", __func__);
 	goto out;
 }
 
@@ -1232,7 +1234,7 @@ static int wl3501_close(struct net_device *dev)
 	wl3501_block_interrupt(this);
 
 	rc = 0;
-	printk(KERN_INFO "%s: WL3501 closed\n", dev->name);
+	pr_info("%s: WL3501 closed\n", dev->name);
 	spin_unlock_irqrestore(&this->lock, flags);
 	return rc;
 }
@@ -1253,8 +1255,7 @@ static int wl3501_reset(struct net_device *dev)
 	wl3501_block_interrupt(this);
 
 	if (wl3501_init_firmware(this)) {
-		printk(KERN_WARNING "%s: Can't initialize Firmware!\n",
-		       dev->name);
+		pr_warn("%s: Can't initialize Firmware!\n", dev->name);
 		/* Free IRQ, and mark IRQ as unused */
 		free_irq(dev->irq, dev);
 		goto out;
@@ -1268,7 +1269,7 @@ static int wl3501_reset(struct net_device *dev)
 	wl3501_ack_interrupt(this);
 	wl3501_unblock_interrupt(this);
 	wl3501_mgmt_scan(this, 100);
-	pr_debug("%s: device reset", dev->name);
+	pr_debug("%s: device reset\n", dev->name);
 	rc = 0;
 out:
 	return rc;
@@ -1286,7 +1287,7 @@ static void wl3501_tx_timeout(struct net_device *dev)
 	rc = wl3501_reset(dev);
 	spin_unlock_irqrestore(&this->lock, flags);
 	if (rc)
-		printk(KERN_ERR "%s: Error %d resetting card on Tx timeout!\n",
+		pr_err("%s: Error %d resetting card on Tx timeout!\n",
 		       dev->name, rc);
 	else {
 		dev->trans_start = jiffies; /* prevent tx timeout */
@@ -1341,7 +1342,7 @@ static int wl3501_open(struct net_device *dev)
 	link->open++;
 
 	/* Initial WL3501 firmware */
-	pr_debug("%s: Initialize WL3501 firmware...", dev->name);
+	pr_debug("%s: Initialize WL3501 firmware...\n", dev->name);
 	if (wl3501_init_firmware(this))
 		goto fail;
 	/* Initial device variables */
@@ -1353,16 +1354,14 @@ static int wl3501_open(struct net_device *dev)
 	wl3501_unblock_interrupt(this);
 	wl3501_mgmt_scan(this, 100);
 	rc = 0;
-	pr_debug("%s: WL3501 opened", dev->name);
-	printk(KERN_INFO "%s: Card Name: %s\n"
-			 "%s: Firmware Date: %s\n",
-			 dev->name, this->card_name,
-			 dev->name, this->firmware_date);
+	pr_debug("%s: WL3501 opened\n", dev->name);
+	pr_info("%s: Card Name: %s\n", dev->name, this->card_name);
+	pr_info("%s: Firmware Date: %s\n", dev->name, this->firmware_date);
 out:
 	spin_unlock_irqrestore(&this->lock, flags);
 	return rc;
 fail:
-	printk(KERN_WARNING "%s: Can't initialize firmware!\n", dev->name);
+	pr_warn("%s: Can't initialize firmware!\n", dev->name);
 	goto out;
 }
 
@@ -1922,7 +1921,7 @@ static int wl3501_config(struct pcmcia_device *link)
 	dev->base_addr = link->resource[0]->start;
 	SET_NETDEV_DEV(dev, &link->dev);
 	if (register_netdev(dev)) {
-		printk(KERN_NOTICE "wl3501_cs: register_netdev() failed\n");
+		pr_notice("register_netdev() failed\n");
 		goto failed;
 	}
 
@@ -1931,8 +1930,7 @@ static int wl3501_config(struct pcmcia_device *link)
 	this->base_addr = dev->base_addr;
 
 	if (!wl3501_get_flash_mac_addr(this)) {
-		printk(KERN_WARNING "%s: Can't read MAC addr in flash ROM?\n",
-		       dev->name);
+		pr_warn("%s: Can't read MAC addr in flash ROM?\n", dev->name);
 		unregister_netdev(dev);
 		goto failed;
 	}
@@ -1941,10 +1939,8 @@ static int wl3501_config(struct pcmcia_device *link)
 		dev->dev_addr[i] = ((char *)&this->mac_addr)[i];
 
 	/* print probe information */
-	printk(KERN_INFO "%s: wl3501 @ 0x%3.3x, IRQ %d, "
-	       "MAC addr in flash ROM:%pM\n",
-	       dev->name, this->base_addr, (int)dev->irq,
-	       dev->dev_addr);
+	pr_info("%s: wl3501 @ 0x%3.3x, IRQ %d, MAC addr in flash ROM:%pM\n",
+		dev->name, this->base_addr, (int)dev->irq, dev->dev_addr);
 	/*
 	 * Initialize card parameters - added by jss
 	 */
-- 
1.7.8.111.gad25c.dirty
