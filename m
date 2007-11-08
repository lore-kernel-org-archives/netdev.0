From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'fixes-jgarzik' branch of wireless-2.6 (3rd time is
	the charm?)
Date: Thu, 8 Nov 2007 09:26:26 -0500
Message-ID: <20071108142626.GH11957@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2221 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754198AbXKHO0v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Nov 2007 09:26:51 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff,

OK, I think things are settled now.  I apologize for the confusion.

These are fixes intended for 2.6.24.  Please note that three of the
patches from Michael Buesch in the list below were already sent to
you directed for 2.6.25.  Upon further review, I think they belong in
2.6.24 instead.  I cherry-picked them, so I'm fairly certain git will
be smart enough to drop them from your 2.6.25 branch when you rebase.

Please let me know if there are any problems.

Thanks!

John

---

Individual patches are available here:

	http://www.kernel.org/pub//linux/kernel/people/linville/wireless-2.6/fixes-jgarzik/

---

The following changes since commit 2655e2cee2d77459fcb7e10228259e4ee0328697:
  Alan Cox (1):
        ata_piix: Add additional PCI identifier for 40 wire short cable

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git fixes-jgarzik

Holger Schurig (1):
      libertas: fixes for slow hardware

Ivo van Doorn (1):
      rt2x00: Block adhoc & master mode

John W. Linville (1):
      hermes: clarify Intel reference in Kconfig help

Marcelo Tosatti (1):
      libertas: properly account for queue commands

Michael Buesch (7):
      b43: pcmcia-host initialization bugfixes
      b43: Fix rfkill callback deadlock
      b43: debugfs SHM read buffer overrun fix
      b43: Rewrite and fix rfkill init
      b43: properly request pcmcia IRQ
      b43legacy: Fix sparse warning
      b43: Fix kconfig dependencies for rfkill and leds

Pierre Ossman (1):
      libertas: make if_sdio align packets

Randy Dunlap (1):
      hostap: fix section mismatch warning

Roel Kluin (1):
      ipw2100: fix postfix decrement errors

Stefano Brivio (4):
      b43legacy: fix possible buffer overrun in debugfs
      b43legacy: add me as maintainer and fix URLs
      b43: fix shared IRQ race condition
      b43legacy: fix shared IRQ race condition

 MAINTAINERS                              |   10 ++-
 drivers/net/wireless/Kconfig             |    2 +-
 drivers/net/wireless/b43/Kconfig         |   10 ++-
 drivers/net/wireless/b43/debugfs.c       |    2 +-
 drivers/net/wireless/b43/main.c          |   19 +++---
 drivers/net/wireless/b43/pcmcia.c        |   52 +++++++++-----
 drivers/net/wireless/b43/rfkill.c        |  115 +++++++++++++----------------
 drivers/net/wireless/b43/rfkill.h        |   14 +---
 drivers/net/wireless/b43legacy/debugfs.c |    2 +-
 drivers/net/wireless/b43legacy/main.c    |   21 +++---
 drivers/net/wireless/hostap/hostap_pci.c |    6 +-
 drivers/net/wireless/ipw2100.c           |    4 +-
 drivers/net/wireless/libertas/cmd.c      |   10 ++-
 drivers/net/wireless/libertas/if_cs.c    |    7 ++-
 drivers/net/wireless/libertas/if_sdio.c  |    4 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c  |    8 ++
 16 files changed, 154 insertions(+), 132 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 1c7c229..6a97027 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -787,23 +787,25 @@ B43 WIRELESS DRIVER
 P:	Michael Buesch
 M:	mb@bu3sch.de
 P:	Stefano Brivio
-M:	st3@riseup.net
+M:	stefano.brivio@polimi.it
 L:	linux-wireless@vger.kernel.org
-W:	http://bcm43xx.berlios.de/
+W:	http://linuxwireless.org/en/users/Drivers/b43
 S:	Maintained
 
 B43LEGACY WIRELESS DRIVER
 P:	Larry Finger
 M:	Larry.Finger@lwfinger.net
+P:	Stefano Brivio
+M:	stefano.brivio@polimi.it
 L:	linux-wireless@vger.kernel.org
-W:	http://bcm43xx.berlios.de/
+W:	http://linuxwireless.org/en/users/Drivers/b43
 S:	Maintained
 
 BCM43XX WIRELESS DRIVER (SOFTMAC BASED VERSION)
 P:	Larry Finger
 M:	Larry.Finger@lwfinger.net
 P:	Stefano Brivio
-M:	st3@riseup.net
+M:	stefano.brivio@polimi.it
 L:	linux-wireless@vger.kernel.org
 W:	http://bcm43xx.berlios.de/
 S:	Maintained
diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index dae5c8d..2b733c5 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -325,7 +325,7 @@ config HERMES
 	  Cabletron/EnteraSys Roamabout, ELSA AirLancer, MELCO Buffalo, Avaya,
 	  IBM High Rate Wireless, Farralon Syyline, Samsung MagicLAN, Netgear
 	  MA401, LinkSys WPC-11, D-Link DWL-650, 3Com AirConnect, Intel
-	  PRO/Wireless, and Symbol Spectrum24 High Rate amongst others.
+	  IPW2011, and Symbol Spectrum24 High Rate amongst others.
 
 	  This option includes the guts of the driver, but in order to
 	  actually use a card you will also need to enable support for PCMCIA
diff --git a/drivers/net/wireless/b43/Kconfig b/drivers/net/wireless/b43/Kconfig
index e3c573e..fdbc351 100644
--- a/drivers/net/wireless/b43/Kconfig
+++ b/drivers/net/wireless/b43/Kconfig
@@ -61,16 +61,18 @@ config B43_PCMCIA
 
 	  If unsure, say N.
 
-# LED support
+# This config option automatically enables b43 LEDS support,
+# if it's possible.
 config B43_LEDS
 	bool
-	depends on B43 && MAC80211_LEDS
+	depends on B43 && MAC80211_LEDS && (LEDS_CLASS = y || LEDS_CLASS = B43)
 	default y
 
-# RFKILL support
+# This config option automatically enables b43 RFKILL support,
+# if it's possible.
 config B43_RFKILL
 	bool
-	depends on B43 && RFKILL && RFKILL_INPUT && INPUT_POLLDEV
+	depends on B43 && (RFKILL = y || RFKILL = B43) && RFKILL_INPUT && (INPUT_POLLDEV = y || INPUT_POLLDEV = B43)
 	default y
 
 config B43_DEBUG
diff --git a/drivers/net/wireless/b43/debugfs.c b/drivers/net/wireless/b43/debugfs.c
index 734e70e..ef0075d 100644
--- a/drivers/net/wireless/b43/debugfs.c
+++ b/drivers/net/wireless/b43/debugfs.c
@@ -128,7 +128,7 @@ static ssize_t shm_read_file(struct b43_wldev *dev,
 	__le16 *le16buf = (__le16 *)buf;
 
 	for (i = 0; i < 0x1000; i++) {
-		if (bufsize <= 0)
+		if (bufsize < sizeof(tmp))
 			break;
 		tmp = b43_shm_read16(dev, B43_SHM_SHARED, 2 * i);
 		le16buf[i] = cpu_to_le16(tmp);
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index 5058e60..2b17c1d 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -2985,6 +2985,16 @@ static void b43_wireless_core_stop(struct b43_wldev *dev)
 
 	if (b43_status(dev) < B43_STAT_STARTED)
 		return;
+
+	/* Disable and sync interrupts. We must do this before than
+	 * setting the status to INITIALIZED, as the interrupt handler
+	 * won't care about IRQs then. */
+	spin_lock_irqsave(&wl->irq_lock, flags);
+	dev->irq_savedstate = b43_interrupt_disable(dev, B43_IRQ_ALL);
+	b43_read32(dev, B43_MMIO_GEN_IRQ_MASK);	/* flush */
+	spin_unlock_irqrestore(&wl->irq_lock, flags);
+	b43_synchronize_irq(dev);
+
 	b43_set_status(dev, B43_STAT_INITIALIZED);
 
 	mutex_unlock(&wl->mutex);
@@ -2995,13 +3005,6 @@ static void b43_wireless_core_stop(struct b43_wldev *dev)
 
 	ieee80211_stop_queues(wl->hw);	//FIXME this could cause a deadlock, as mac80211 seems buggy.
 
-	/* Disable and sync interrupts. */
-	spin_lock_irqsave(&wl->irq_lock, flags);
-	dev->irq_savedstate = b43_interrupt_disable(dev, B43_IRQ_ALL);
-	b43_read32(dev, B43_MMIO_GEN_IRQ_MASK);	/* flush */
-	spin_unlock_irqrestore(&wl->irq_lock, flags);
-	b43_synchronize_irq(dev);
-
 	b43_mac_suspend(dev);
 	free_irq(dev->dev->irq, dev);
 	b43dbg(wl, "Wireless interface stopped\n");
@@ -3661,7 +3664,6 @@ static int b43_setup_modes(struct b43_wldev *dev,
 
 static void b43_wireless_core_detach(struct b43_wldev *dev)
 {
-	b43_rfkill_free(dev);
 	/* We release firmware that late to not be required to re-request
 	 * is all the time when we reinit the core. */
 	b43_release_firmware(dev);
@@ -3747,7 +3749,6 @@ static int b43_wireless_core_attach(struct b43_wldev *dev)
 	if (!wl->current_dev)
 		wl->current_dev = dev;
 	INIT_WORK(&dev->restart_work, b43_chip_reset);
-	b43_rfkill_alloc(dev);
 
 	b43_radio_turn_off(dev, 1);
 	b43_switch_analog(dev, 0);
diff --git a/drivers/net/wireless/b43/pcmcia.c b/drivers/net/wireless/b43/pcmcia.c
index b242a9a..b79a6bd 100644
--- a/drivers/net/wireless/b43/pcmcia.c
+++ b/drivers/net/wireless/b43/pcmcia.c
@@ -65,12 +65,12 @@ static int __devinit b43_pcmcia_probe(struct pcmcia_device *dev)
 	tuple_t tuple;
 	cisparse_t parse;
 	int err = -ENOMEM;
-	int res;
+	int res = 0;
 	unsigned char buf[64];
 
 	ssb = kzalloc(sizeof(*ssb), GFP_KERNEL);
 	if (!ssb)
-		goto out;
+		goto out_error;
 
 	err = -ENODEV;
 	tuple.DesiredTuple = CISTPL_CONFIG;
@@ -96,10 +96,12 @@ static int __devinit b43_pcmcia_probe(struct pcmcia_device *dev)
 	dev->io.NumPorts2 = 0;
 	dev->io.Attributes2 = 0;
 
-	win.Attributes = WIN_MEMORY_TYPE_CM | WIN_ENABLE | WIN_USE_WAIT;
+	win.Attributes = WIN_ADDR_SPACE_MEM | WIN_MEMORY_TYPE_CM |
+			 WIN_ENABLE | WIN_DATA_WIDTH_16 |
+			 WIN_USE_WAIT;
 	win.Base = 0;
 	win.Size = SSB_CORE_SIZE;
-	win.AccessSpeed = 1000;
+	win.AccessSpeed = 250;
 	res = pcmcia_request_window(&dev, &win, &dev->win);
 	if (res != CS_SUCCESS)
 		goto err_kfree_ssb;
@@ -108,21 +110,34 @@ static int __devinit b43_pcmcia_probe(struct pcmcia_device *dev)
 	mem.Page = 0;
 	res = pcmcia_map_mem_page(dev->win, &mem);
 	if (res != CS_SUCCESS)
-		goto err_kfree_ssb;
+		goto err_disable;
+
+	dev->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING | IRQ_FIRST_SHARED;
+	dev->irq.IRQInfo1 = IRQ_LEVEL_ID | IRQ_SHARE_ID;
+	dev->irq.Handler = NULL; /* The handler is registered later. */
+	dev->irq.Instance = NULL;
+	res = pcmcia_request_irq(dev, &dev->irq);
+	if (res != CS_SUCCESS)
+		goto err_disable;
 
 	res = pcmcia_request_configuration(dev, &dev->conf);
 	if (res != CS_SUCCESS)
 		goto err_disable;
 
 	err = ssb_bus_pcmciabus_register(ssb, dev, win.Base);
+	if (err)
+		goto err_disable;
 	dev->priv = ssb;
 
-      out:
-	return err;
-      err_disable:
+	return 0;
+
+err_disable:
 	pcmcia_disable_device(dev);
-      err_kfree_ssb:
+err_kfree_ssb:
 	kfree(ssb);
+out_error:
+	printk(KERN_ERR "b43-pcmcia: Initialization failed (%d, %d)\n",
+	       res, err);
 	return err;
 }
 
@@ -131,22 +146,21 @@ static void __devexit b43_pcmcia_remove(struct pcmcia_device *dev)
 	struct ssb_bus *ssb = dev->priv;
 
 	ssb_bus_unregister(ssb);
-	pcmcia_release_window(dev->win);
 	pcmcia_disable_device(dev);
 	kfree(ssb);
 	dev->priv = NULL;
 }
 
 static struct pcmcia_driver b43_pcmcia_driver = {
-	.owner = THIS_MODULE,
-	.drv = {
-		.name = "b43-pcmcia",
-		},
-	.id_table = b43_pcmcia_tbl,
-	.probe = b43_pcmcia_probe,
-	.remove = b43_pcmcia_remove,
-	.suspend = b43_pcmcia_suspend,
-	.resume = b43_pcmcia_resume,
+	.owner		= THIS_MODULE,
+	.drv		= {
+				.name = "b43-pcmcia",
+			},
+	.id_table	= b43_pcmcia_tbl,
+	.probe		= b43_pcmcia_probe,
+	.remove		= __devexit_p(b43_pcmcia_remove),
+	.suspend	= b43_pcmcia_suspend,
+	.resume		= b43_pcmcia_resume,
 };
 
 int b43_pcmcia_init(void)
diff --git a/drivers/net/wireless/b43/rfkill.c b/drivers/net/wireless/b43/rfkill.c
index 800e0a6..9b1f905 100644
--- a/drivers/net/wireless/b43/rfkill.c
+++ b/drivers/net/wireless/b43/rfkill.c
@@ -47,32 +47,35 @@ static void b43_rfkill_poll(struct input_polled_dev *poll_dev)
 	struct b43_wldev *dev = poll_dev->private;
 	struct b43_wl *wl = dev->wl;
 	bool enabled;
+	bool report_change = 0;
 
 	mutex_lock(&wl->mutex);
 	B43_WARN_ON(b43_status(dev) < B43_STAT_INITIALIZED);
 	enabled = b43_is_hw_radio_enabled(dev);
 	if (unlikely(enabled != dev->radio_hw_enable)) {
 		dev->radio_hw_enable = enabled;
+		report_change = 1;
 		b43info(wl, "Radio hardware status changed to %s\n",
 			enabled ? "ENABLED" : "DISABLED");
-		mutex_unlock(&wl->mutex);
+	}
+	mutex_unlock(&wl->mutex);
+
+	if (unlikely(report_change))
 		input_report_key(poll_dev->input, KEY_WLAN, enabled);
-	} else
-		mutex_unlock(&wl->mutex);
 }
 
-/* Called when the RFKILL toggled in software.
- * This is called without locking. */
+/* Called when the RFKILL toggled in software. */
 static int b43_rfkill_soft_toggle(void *data, enum rfkill_state state)
 {
 	struct b43_wldev *dev = data;
 	struct b43_wl *wl = dev->wl;
 	int err = 0;
 
-	mutex_lock(&wl->mutex);
-	if (b43_status(dev) < B43_STAT_INITIALIZED)
-		goto out_unlock;
+	if (!wl->rfkill.registered)
+		return 0;
 
+	mutex_lock(&wl->mutex);
+	B43_WARN_ON(b43_status(dev) < B43_STAT_INITIALIZED);
 	switch (state) {
 	case RFKILL_STATE_ON:
 		if (!dev->radio_hw_enable) {
@@ -89,7 +92,6 @@ static int b43_rfkill_soft_toggle(void *data, enum rfkill_state state)
 			b43_radio_turn_off(dev, 0);
 		break;
 	}
-
 out_unlock:
 	mutex_unlock(&wl->mutex);
 
@@ -98,11 +100,11 @@ out_unlock:
 
 char * b43_rfkill_led_name(struct b43_wldev *dev)
 {
-	struct b43_wl *wl = dev->wl;
+	struct b43_rfkill *rfk = &(dev->wl->rfkill);
 
-	if (!wl->rfkill.rfkill)
+	if (!rfk->registered)
 		return NULL;
-	return rfkill_get_led_name(wl->rfkill.rfkill);
+	return rfkill_get_led_name(rfk->rfkill);
 }
 
 void b43_rfkill_init(struct b43_wldev *dev)
@@ -111,53 +113,13 @@ void b43_rfkill_init(struct b43_wldev *dev)
 	struct b43_rfkill *rfk = &(wl->rfkill);
 	int err;
 
-	if (rfk->rfkill) {
-		err = rfkill_register(rfk->rfkill);
-		if (err) {
-			b43warn(wl, "Failed to register RF-kill button\n");
-			goto err_free_rfk;
-		}
-	}
-	if (rfk->poll_dev) {
-		err = input_register_polled_device(rfk->poll_dev);
-		if (err) {
-			b43warn(wl, "Failed to register RF-kill polldev\n");
-			goto err_free_polldev;
-		}
-	}
-
-	return;
-err_free_rfk:
-	rfkill_free(rfk->rfkill);
-	rfk->rfkill = NULL;
-err_free_polldev:
-	input_free_polled_device(rfk->poll_dev);
-	rfk->poll_dev = NULL;
-}
-
-void b43_rfkill_exit(struct b43_wldev *dev)
-{
-	struct b43_rfkill *rfk = &(dev->wl->rfkill);
-
-	if (rfk->poll_dev)
-		input_unregister_polled_device(rfk->poll_dev);
-	if (rfk->rfkill)
-		rfkill_unregister(rfk->rfkill);
-}
-
-void b43_rfkill_alloc(struct b43_wldev *dev)
-{
-	struct b43_wl *wl = dev->wl;
-	struct b43_rfkill *rfk = &(wl->rfkill);
+	rfk->registered = 0;
 
+	rfk->rfkill = rfkill_allocate(dev->dev->dev, RFKILL_TYPE_WLAN);
+	if (!rfk->rfkill)
+		goto out_error;
 	snprintf(rfk->name, sizeof(rfk->name),
 		 "b43-%s", wiphy_name(wl->hw->wiphy));
-
-	rfk->rfkill = rfkill_allocate(dev->dev->dev, RFKILL_TYPE_WLAN);
-	if (!rfk->rfkill) {
-		b43warn(wl, "Failed to allocate RF-kill button\n");
-		return;
-	}
 	rfk->rfkill->name = rfk->name;
 	rfk->rfkill->state = RFKILL_STATE_ON;
 	rfk->rfkill->data = dev;
@@ -165,18 +127,45 @@ void b43_rfkill_alloc(struct b43_wldev *dev)
 	rfk->rfkill->user_claim_unsupported = 1;
 
 	rfk->poll_dev = input_allocate_polled_device();
-	if (rfk->poll_dev) {
-		rfk->poll_dev->private = dev;
-		rfk->poll_dev->poll = b43_rfkill_poll;
-		rfk->poll_dev->poll_interval = 1000; /* msecs */
-	} else
-		b43warn(wl, "Failed to allocate RF-kill polldev\n");
+	if (!rfk->poll_dev)
+		goto err_free_rfk;
+	rfk->poll_dev->private = dev;
+	rfk->poll_dev->poll = b43_rfkill_poll;
+	rfk->poll_dev->poll_interval = 1000; /* msecs */
+
+	err = rfkill_register(rfk->rfkill);
+	if (err)
+		goto err_free_polldev;
+	err = input_register_polled_device(rfk->poll_dev);
+	if (err)
+		goto err_unreg_rfk;
+
+	rfk->registered = 1;
+
+	return;
+err_unreg_rfk:
+	rfkill_unregister(rfk->rfkill);
+err_free_polldev:
+	input_free_polled_device(rfk->poll_dev);
+	rfk->poll_dev = NULL;
+err_free_rfk:
+	rfkill_free(rfk->rfkill);
+	rfk->rfkill = NULL;
+out_error:
+	rfk->registered = 0;
+	b43warn(wl, "RF-kill button init failed\n");
 }
 
-void b43_rfkill_free(struct b43_wldev *dev)
+void b43_rfkill_exit(struct b43_wldev *dev)
 {
 	struct b43_rfkill *rfk = &(dev->wl->rfkill);
 
+	if (!rfk->registered)
+		return;
+	rfk->registered = 0;
+
+	input_unregister_polled_device(rfk->poll_dev);
+	rfkill_unregister(rfk->rfkill);
 	input_free_polled_device(rfk->poll_dev);
 	rfk->poll_dev = NULL;
 	rfkill_free(rfk->rfkill);
diff --git a/drivers/net/wireless/b43/rfkill.h b/drivers/net/wireless/b43/rfkill.h
index 29544e8..adacf93 100644
--- a/drivers/net/wireless/b43/rfkill.h
+++ b/drivers/net/wireless/b43/rfkill.h
@@ -15,14 +15,14 @@ struct b43_rfkill {
 	struct rfkill *rfkill;
 	/* The poll device for the RFKILL input button */
 	struct input_polled_dev *poll_dev;
+	/* Did initialization succeed? Used for freeing. */
+	bool registered;
 	/* The unique name of this rfkill switch */
-	char name[32];
+	char name[sizeof("b43-phy4294967295")];
 };
 
-/* All the init functions return void, because we are not interested
+/* The init function returns void, because we are not interested
  * in failing the b43 init process when rfkill init failed. */
-void b43_rfkill_alloc(struct b43_wldev *dev);
-void b43_rfkill_free(struct b43_wldev *dev);
 void b43_rfkill_init(struct b43_wldev *dev);
 void b43_rfkill_exit(struct b43_wldev *dev);
 
@@ -36,12 +36,6 @@ struct b43_rfkill {
 	/* empty */
 };
 
-static inline void b43_rfkill_alloc(struct b43_wldev *dev)
-{
-}
-static inline void b43_rfkill_free(struct b43_wldev *dev)
-{
-}
 static inline void b43_rfkill_init(struct b43_wldev *dev)
 {
 }
diff --git a/drivers/net/wireless/b43legacy/debugfs.c b/drivers/net/wireless/b43legacy/debugfs.c
index eefa6fb..619b453 100644
--- a/drivers/net/wireless/b43legacy/debugfs.c
+++ b/drivers/net/wireless/b43legacy/debugfs.c
@@ -124,7 +124,7 @@ static ssize_t shm_read_file(struct b43legacy_wldev *dev, char *buf, size_t bufs
 	__le16 *le16buf = (__le16 *)buf;
 
 	for (i = 0; i < 0x1000; i++) {
-		if (bufsize <= 0)
+		if (bufsize < sizeof(tmp))
 			break;
 		tmp = b43legacy_shm_read16(dev, B43legacy_SHM_SHARED, 2 * i);
 		le16buf[i] = cpu_to_le16(tmp);
diff --git a/drivers/net/wireless/b43legacy/main.c b/drivers/net/wireless/b43legacy/main.c
index f0e56df..3bde1e9 100644
--- a/drivers/net/wireless/b43legacy/main.c
+++ b/drivers/net/wireless/b43legacy/main.c
@@ -2781,6 +2781,17 @@ static void b43legacy_wireless_core_stop(struct b43legacy_wldev *dev)
 
 	if (b43legacy_status(dev) < B43legacy_STAT_STARTED)
 		return;
+
+	/* Disable and sync interrupts. We must do this before than
+	 * setting the status to INITIALIZED, as the interrupt handler
+	 * won't care about IRQs then. */
+	spin_lock_irqsave(&wl->irq_lock, flags);
+	dev->irq_savedstate = b43legacy_interrupt_disable(dev,
+							  B43legacy_IRQ_ALL);
+	b43legacy_read32(dev, B43legacy_MMIO_GEN_IRQ_MASK); /* flush */
+	spin_unlock_irqrestore(&wl->irq_lock, flags);
+	b43legacy_synchronize_irq(dev);
+
 	b43legacy_set_status(dev, B43legacy_STAT_INITIALIZED);
 
 	mutex_unlock(&wl->mutex);
@@ -2791,14 +2802,6 @@ static void b43legacy_wireless_core_stop(struct b43legacy_wldev *dev)
 
 	ieee80211_stop_queues(wl->hw); /* FIXME this could cause a deadlock */
 
-	/* Disable and sync interrupts. */
-	spin_lock_irqsave(&wl->irq_lock, flags);
-	dev->irq_savedstate = b43legacy_interrupt_disable(dev,
-							  B43legacy_IRQ_ALL);
-	b43legacy_read32(dev, B43legacy_MMIO_GEN_IRQ_MASK); /* flush */
-	spin_unlock_irqrestore(&wl->irq_lock, flags);
-	b43legacy_synchronize_irq(dev);
-
 	b43legacy_mac_suspend(dev);
 	free_irq(dev->dev->irq, dev);
 	b43legacydbg(wl, "Wireless interface stopped\n");
@@ -3332,7 +3335,7 @@ out_mutex_unlock:
 	return err;
 }
 
-void b43legacy_stop(struct ieee80211_hw *hw)
+static void b43legacy_stop(struct ieee80211_hw *hw)
 {
 	struct b43legacy_wl *wl = hw_to_b43legacy_wl(hw);
 	struct b43legacy_wldev *dev = wl->current_dev;
diff --git a/drivers/net/wireless/hostap/hostap_pci.c b/drivers/net/wireless/hostap/hostap_pci.c
index 7da3664..fc876ba 100644
--- a/drivers/net/wireless/hostap/hostap_pci.c
+++ b/drivers/net/wireless/hostap/hostap_pci.c
@@ -444,7 +444,7 @@ static int prism2_pci_resume(struct pci_dev *pdev)
 
 MODULE_DEVICE_TABLE(pci, prism2_pci_id_table);
 
-static struct pci_driver prism2_pci_drv_id = {
+static struct pci_driver prism2_pci_driver = {
 	.name		= "hostap_pci",
 	.id_table	= prism2_pci_id_table,
 	.probe		= prism2_pci_probe,
@@ -458,13 +458,13 @@ static struct pci_driver prism2_pci_drv_id = {
 
 static int __init init_prism2_pci(void)
 {
-	return pci_register_driver(&prism2_pci_drv_id);
+	return pci_register_driver(&prism2_pci_driver);
 }
 
 
 static void __exit exit_prism2_pci(void)
 {
-	pci_unregister_driver(&prism2_pci_drv_id);
+	pci_unregister_driver(&prism2_pci_driver);
 }
 
 
diff --git a/drivers/net/wireless/ipw2100.c b/drivers/net/wireless/ipw2100.c
index 8d53d08..fc6cdd8 100644
--- a/drivers/net/wireless/ipw2100.c
+++ b/drivers/net/wireless/ipw2100.c
@@ -1267,7 +1267,7 @@ static int ipw2100_start_adapter(struct ipw2100_priv *priv)
 				       IPW2100_INTA_FATAL_ERROR |
 				       IPW2100_INTA_PARITY_ERROR);
 		}
-	} while (i--);
+	} while (--i);
 
 	/* Clear out any pending INTAs since we aren't supposed to have
 	 * interrupts enabled at this point... */
@@ -1339,7 +1339,7 @@ static int ipw2100_power_cycle_adapter(struct ipw2100_priv *priv)
 
 		if (reg & IPW_AUX_HOST_RESET_REG_MASTER_DISABLED)
 			break;
-	} while (i--);
+	} while (--i);
 
 	priv->status &= ~STATUS_RESET_PENDING;
 
diff --git a/drivers/net/wireless/libertas/cmd.c b/drivers/net/wireless/libertas/cmd.c
index 1cbbd96..be5cfd8 100644
--- a/drivers/net/wireless/libertas/cmd.c
+++ b/drivers/net/wireless/libertas/cmd.c
@@ -912,6 +912,10 @@ static int wlan_cmd_set_boot2_ver(wlan_private * priv,
 	return 0;
 }
 
+/*
+ * Note: NEVER use libertas_queue_cmd() with addtail==0 other than for
+ * the command timer, because it does not account for queued commands.
+ */
 void libertas_queue_cmd(wlan_adapter * adapter, struct cmd_ctrl_node *cmdnode, u8 addtail)
 {
 	unsigned long flags;
@@ -941,10 +945,11 @@ void libertas_queue_cmd(wlan_adapter * adapter, struct cmd_ctrl_node *cmdnode, u
 
 	spin_lock_irqsave(&adapter->driver_lock, flags);
 
-	if (addtail)
+	if (addtail) {
 		list_add_tail((struct list_head *)cmdnode,
 			      &adapter->cmdpendingq);
-	else
+		adapter->nr_cmd_pending++;
+	} else
 		list_add((struct list_head *)cmdnode, &adapter->cmdpendingq);
 
 	spin_unlock_irqrestore(&adapter->driver_lock, flags);
@@ -1412,7 +1417,6 @@ int libertas_prepare_and_send_command(wlan_private * priv,
 	cmdnode->cmdwaitqwoken = 0;
 
 	libertas_queue_cmd(adapter, cmdnode, 1);
-	adapter->nr_cmd_pending++;
 	wake_up_interruptible(&priv->waitq);
 
 	if (wait_option & CMD_OPTION_WAITFORRSP) {
diff --git a/drivers/net/wireless/libertas/if_cs.c b/drivers/net/wireless/libertas/if_cs.c
index 0360cad..ec89dab 100644
--- a/drivers/net/wireless/libertas/if_cs.c
+++ b/drivers/net/wireless/libertas/if_cs.c
@@ -148,11 +148,11 @@ static int if_cs_poll_while_fw_download(struct if_cs_card *card, uint addr, u8 r
 {
 	int i;
 
-	for (i = 0; i < 500; i++) {
+	for (i = 0; i < 1000; i++) {
 		u8 val = if_cs_read8(card, addr);
 		if (val == reg)
 			return i;
-		udelay(100);
+		udelay(500);
 	}
 	return -ETIME;
 }
@@ -878,6 +878,9 @@ static int if_cs_probe(struct pcmcia_device *p_dev)
 		goto out3;
 	}
 
+	/* Clear any interrupt cause that happend while sending
+	 * firmware/initializing card */
+	if_cs_write16(card, IF_CS_C_INT_CAUSE, IF_CS_C_IC_MASK);
 	if_cs_enable_ints(card);
 
 	/* And finally bring the card up */
diff --git a/drivers/net/wireless/libertas/if_sdio.c b/drivers/net/wireless/libertas/if_sdio.c
index a8e1707..b24425f 100644
--- a/drivers/net/wireless/libertas/if_sdio.c
+++ b/drivers/net/wireless/libertas/if_sdio.c
@@ -182,12 +182,14 @@ static int if_sdio_handle_data(struct if_sdio_card *card,
 		goto out;
 	}
 
-	skb = dev_alloc_skb(MRVDRV_ETH_RX_PACKET_BUFFER_SIZE);
+	skb = dev_alloc_skb(MRVDRV_ETH_RX_PACKET_BUFFER_SIZE + NET_IP_ALIGN);
 	if (!skb) {
 		ret = -ENOMEM;
 		goto out;
 	}
 
+	skb_reserve(skb, NET_IP_ALIGN);
+
 	data = skb_put(skb, size);
 
 	memcpy(data, buffer, size);
diff --git a/drivers/net/wireless/rt2x00/rt2x00mac.c b/drivers/net/wireless/rt2x00/rt2x00mac.c
index 4a6a0bd..85ea8a8 100644
--- a/drivers/net/wireless/rt2x00/rt2x00mac.c
+++ b/drivers/net/wireless/rt2x00/rt2x00mac.c
@@ -196,6 +196,14 @@ int rt2x00mac_add_interface(struct ieee80211_hw *hw,
 	struct rt2x00_dev *rt2x00dev = hw->priv;
 	struct interface *intf = &rt2x00dev->interface;
 
+	/* FIXME: Beaconing is broken in rt2x00. */
+	if (conf->type == IEEE80211_IF_TYPE_IBSS ||
+	    conf->type == IEEE80211_IF_TYPE_AP) {
+		ERROR(rt2x00dev,
+		      "rt2x00 does not support Adhoc or Master mode");
+		return -EOPNOTSUPP;
+	}
+
 	/*
 	 * Don't allow interfaces to be added while
 	 * either the device has disappeared or when
-- 
John W. Linville
linville@tuxdriver.com
