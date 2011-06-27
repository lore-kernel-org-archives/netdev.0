From: Joe Perches <joe@perches.com>
Subject: [PATCH 3/8] cyclom: Update to current logging forms
Date: Sun, 26 Jun 2011 22:01:30 -0700
Message-ID: <300fe9f0e38fcdf63856f73ec86134085ea762c0.1309150684.git.joe@perches.com>
References: <cover.1309150683.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1309150683.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use pr_fmt, pr_<level> and netdev_<level> as appropriate.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wan/cycx_drv.c  |   81 +++++++++-----------
 drivers/net/wan/cycx_main.c |   31 ++++----
 drivers/net/wan/cycx_x25.c  |  177 ++++++++++++++++++++-----------------------
 3 files changed, 133 insertions(+), 156 deletions(-)

diff --git a/drivers/net/wan/cycx_drv.c b/drivers/net/wan/cycx_drv.c
index 164c362..2a3ecae 100644
--- a/drivers/net/wan/cycx_drv.c
+++ b/drivers/net/wan/cycx_drv.c
@@ -48,6 +48,8 @@
 * Aug  8, 1998	acme		Initial version.
 */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/init.h>		/* __init */
 #include <linux/module.h>
 #include <linux/kernel.h>	/* printk(), and other useful stuff */
@@ -81,10 +83,9 @@ static u16 checksum(u8 *buf, u32 len);
 /* Global Data */
 
 /* private data */
-static const char modname[] = "cycx_drv";
 static const char fullname[] = "Cyclom 2X Support Module";
-static const char copyright[] = "(c) 1998-2003 Arnaldo Carvalho de Melo "
-			  "<acme@conectiva.com.br>";
+static const char copyright[] =
+	"(c) 1998-2003 Arnaldo Carvalho de Melo <acme@conectiva.com.br>";
 
 /* Hardware configuration options.
  * These are arrays of configuration options used by verification routines.
@@ -110,8 +111,8 @@ static const long cycx_2x_irq_options[]  = { 7, 3, 5, 9, 10, 11, 12, 15 };
 
 static int __init cycx_drv_init(void)
 {
-	printk(KERN_INFO "%s v%u.%u %s\n", fullname, MOD_VERSION, MOD_RELEASE,
-			 copyright);
+	pr_info("%s v%u.%u %s\n",
+		fullname, MOD_VERSION, MOD_RELEASE, copyright);
 
 	return 0;
 }
@@ -139,18 +140,16 @@ int cycx_setup(struct cycx_hw *hw, void *cfm, u32 len, unsigned long dpmbase)
 
 	/* Verify IRQ configuration options */
 	if (!get_option_index(cycx_2x_irq_options, hw->irq)) {
-		printk(KERN_ERR "%s: IRQ %d is invalid!\n", modname, hw->irq);
+		pr_err("IRQ %d is invalid!\n", hw->irq);
 		return -EINVAL;
 	}
 
 	/* Setup adapter dual-port memory window and test memory */
 	if (!dpmbase) {
-		printk(KERN_ERR "%s: you must specify the dpm address!\n",
-				modname);
+		pr_err("you must specify the dpm address!\n");
  		return -EINVAL;
 	} else if (!get_option_index(cyc2x_dpmbase_options, dpmbase)) {
-		printk(KERN_ERR "%s: memory address 0x%lX is invalid!\n",
-				modname, dpmbase);
+		pr_err("memory address 0x%lX is invalid!\n", dpmbase);
 		return -EINVAL;
 	}
 
@@ -158,13 +157,12 @@ int cycx_setup(struct cycx_hw *hw, void *cfm, u32 len, unsigned long dpmbase)
 	hw->dpmsize = CYCX_WINDOWSIZE;
 
 	if (!detect_cyc2x(hw->dpmbase)) {
-		printk(KERN_ERR "%s: adapter Cyclom 2X not found at "
-				"address 0x%lX!\n", modname, dpmbase);
+		pr_err("adapter Cyclom 2X not found at address 0x%lX!\n",
+		       dpmbase);
 		return -EINVAL;
 	}
 
-	printk(KERN_INFO "%s: found Cyclom 2X card at address 0x%lX.\n",
-			 modname, dpmbase);
+	pr_info("found Cyclom 2X card at address 0x%lX\n", dpmbase);
 
 	/* Load firmware. If loader fails then shut down adapter */
 	err = load_cyc2x(hw, cfm, len);
@@ -339,7 +337,7 @@ static int cycx_data_boot(void __iomem *addr, u8 *code, u32 len)
 	for (i = 0 ; i < len ; i += CFM_LOAD_BUFSZ)
 		if (buffer_load(addr, code + i,
 				min_t(u32, CFM_LOAD_BUFSZ, (len - i))) < 0) {
-			printk(KERN_ERR "%s: Error !!\n", modname);
+			pr_err("Error !!\n");
 			return -1;
 		}
 
@@ -370,7 +368,7 @@ static int cycx_code_boot(void __iomem *addr, u8 *code, u32 len)
 	for (i = 0 ; i < len ; i += CFM_LOAD_BUFSZ)
 		if (buffer_load(addr, code + i,
 				min_t(u32, CFM_LOAD_BUFSZ, (len - i)))) {
-			printk(KERN_ERR "%s: Error !!\n", modname);
+			pr_err("Error !!\n");
 			return -1;
 		}
 
@@ -391,23 +389,20 @@ static int load_cyc2x(struct cycx_hw *hw, struct cycx_firmware *cfm, u32 len)
 	u16 cksum;
 
 	/* Announce */
-	printk(KERN_INFO "%s: firmware signature=\"%s\"\n", modname,
-							    cfm->signature);
+	pr_info("firmware signature=\"%s\"\n", cfm->signature);
 
 	/* Verify firmware signature */
 	if (strcmp(cfm->signature, CFM_SIGNATURE)) {
-		printk(KERN_ERR "%s:load_cyc2x: not Cyclom-2X firmware!\n",
-				modname);
+		pr_err("load_cyc2x: not Cyclom-2X firmware!\n");
 		return -EINVAL;
 	}
 
-	printk(KERN_INFO "%s: firmware version=%u\n", modname, cfm->version);
+	pr_info("firmware version=%u\n", cfm->version);
 
 	/* Verify firmware module format version */
 	if (cfm->version != CFM_VERSION) {
-		printk(KERN_ERR "%s:%s: firmware format %u rejected! "
-				"Expecting %u.\n",
-				modname, __func__, cfm->version, CFM_VERSION);
+		pr_err("%s: firmware format %u rejected! Expecting %u.\n",
+		       __func__, cfm->version, CFM_VERSION);
 		return -EINVAL;
 	}
 
@@ -419,23 +414,22 @@ static int load_cyc2x(struct cycx_hw *hw, struct cycx_firmware *cfm, u32 len)
 	if (((len - sizeof(struct cycx_firmware) - 1) != cfm->info.codesize) ||
 */
 	if (cksum != cfm->checksum) {
-		printk(KERN_ERR "%s:%s: firmware corrupted!\n",
-				modname, __func__);
-		printk(KERN_ERR " cdsize = 0x%x (expected 0x%lx)\n",
-				len - (int)sizeof(struct cycx_firmware) - 1,
-				cfm->info.codesize);
-		printk(KERN_ERR " chksum = 0x%x (expected 0x%x)\n",
-				cksum, cfm->checksum);
+		pr_err("%s: firmware corrupted!\n", __func__);
+		pr_err(" cdsize = 0x%x (expected 0x%lx)\n",
+		       len - (int)sizeof(struct cycx_firmware) - 1,
+		       cfm->info.codesize);
+		pr_err(" chksum = 0x%x (expected 0x%x)\n",
+		       cksum, cfm->checksum);
 		return -EINVAL;
 	}
 
 	/* If everything is ok, set reset, data and code pointers */
 	img_hdr = (struct cycx_fw_header *)&cfm->image;
 #ifdef FIRMWARE_DEBUG
-	printk(KERN_INFO "%s:%s: image sizes\n", __func__, modname);
-	printk(KERN_INFO " reset=%lu\n", img_hdr->reset_size);
-	printk(KERN_INFO "  data=%lu\n", img_hdr->data_size);
-	printk(KERN_INFO "  code=%lu\n", img_hdr->code_size);
+	pr_info("%s: image sizes\n", __func__);
+	pr_info(" reset=%lu\n", img_hdr->reset_size);
+	pr_info("  data=%lu\n", img_hdr->data_size);
+	pr_info("  code=%lu\n", img_hdr->code_size);
 #endif
 	reset_image = ((u8 *)img_hdr) + sizeof(struct cycx_fw_header);
 	data_image = reset_image + img_hdr->reset_size;
@@ -443,15 +437,14 @@ static int load_cyc2x(struct cycx_hw *hw, struct cycx_firmware *cfm, u32 len)
 
 	/*---- Start load ----*/
 	/* Announce */
-	printk(KERN_INFO "%s: loading firmware %s (ID=%u)...\n", modname,
-			 cfm->descr[0] ? cfm->descr : "unknown firmware",
-			 cfm->info.codeid);
+	pr_info("loading firmware %s (ID=%u)...\n",
+		cfm->descr[0] ? cfm->descr : "unknown firmware",
+		cfm->info.codeid);
 
 	for (i = 0 ; i < 5 ; i++) {
 		/* Reset Cyclom hardware */
 		if (!reset_cyc2x(hw->dpmbase)) {
-			printk(KERN_ERR "%s: dpm problem or board not found\n",
-					modname);
+			pr_err("dpm problem or board not found\n");
 			return -EINVAL;
 		}
 
@@ -468,19 +461,19 @@ static int load_cyc2x(struct cycx_hw *hw, struct cycx_firmware *cfm, u32 len)
 				msleep_interruptible(1 * 1000);
 	}
 
-	printk(KERN_ERR "%s: reset not started.\n", modname);
+	pr_err("reset not started\n");
 	return -EINVAL;
 
 reset_loaded:
 	/* Load data.bin */
 	if (cycx_data_boot(hw->dpmbase, data_image, img_hdr->data_size)) {
-		printk(KERN_ERR "%s: cannot load data file.\n", modname);
+		pr_err("cannot load data file\n");
 		return -EINVAL;
 	}
 
 	/* Load code.bin */
 	if (cycx_code_boot(hw->dpmbase, code_image, img_hdr->code_size)) {
-		printk(KERN_ERR "%s: cannot load code file.\n", modname);
+		pr_err("cannot load code file\n");
 		return -EINVAL;
 	}
 
@@ -493,7 +486,7 @@ reset_loaded:
 	/* Arthur Ganzert's tip: wait a while after the firmware loading...
 	   seg abr 26 17:17:12 EST 1999 - acme */
 	msleep_interruptible(7 * 1000);
-	printk(KERN_INFO "%s: firmware loaded!\n", modname);
+	pr_info("firmware loaded!\n");
 
 	/* enable interrupts */
 	cycx_inten(hw);
diff --git a/drivers/net/wan/cycx_main.c b/drivers/net/wan/cycx_main.c
index a0976d1..81fbbad 100644
--- a/drivers/net/wan/cycx_main.c
+++ b/drivers/net/wan/cycx_main.c
@@ -40,6 +40,8 @@
 * 1998/08/08	acme		Initial version.
 */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/stddef.h>	/* offsetof(), etc. */
 #include <linux/errno.h>	/* return codes */
 #include <linux/string.h>	/* inline memset(), etc. */
@@ -107,7 +109,7 @@ static int __init cycx_init(void)
 {
 	int cnt, err = -ENOMEM;
 
-	printk(KERN_INFO "%s v%u.%u %s\n",
+	pr_info("%s v%u.%u %s\n",
 		cycx_fullname, CYCX_DRV_VERSION, CYCX_DRV_RELEASE,
 		cycx_copyright);
 
@@ -133,9 +135,8 @@ static int __init cycx_init(void)
 		err = register_wan_device(wandev);
 
 		if (err) {
-			printk(KERN_ERR "%s: %s registration failed with "
-					"error %d!\n",
-					cycx_drvname, card->devname, err);
+			pr_err("%s registration failed with error %d!\n",
+			       card->devname, err);
 			break;
 		}
 	}
@@ -198,14 +199,13 @@ static int cycx_wan_setup(struct wan_device *wandev, wandev_conf_t *conf)
 
 	rc = -EINVAL;
 	if (!conf->data_size || !conf->data) {
-		printk(KERN_ERR "%s: firmware not found in configuration "
-				"data!\n", wandev->name);
+		pr_err("%s: firmware not found in configuration data!\n",
+		       wandev->name);
 		goto out;
 	}
 
 	if (conf->irq <= 0) {
-		printk(KERN_ERR "%s: can't configure without IRQ!\n",
-				wandev->name);
+		pr_err("%s: can't configure without IRQ!\n", wandev->name);
 		goto out;
 	}
 
@@ -213,8 +213,7 @@ static int cycx_wan_setup(struct wan_device *wandev, wandev_conf_t *conf)
 	irq = conf->irq == 2 ? 9 : conf->irq;	/* IRQ2 -> IRQ9 */
 
 	if (request_irq(irq, cycx_isr, 0, wandev->name, card)) {
-		printk(KERN_ERR "%s: can't reserve IRQ %d!\n",
-				wandev->name, irq);
+		pr_err("%s: can't reserve IRQ %d!\n", wandev->name, irq);
 		goto out;
 	}
 
@@ -246,8 +245,7 @@ static int cycx_wan_setup(struct wan_device *wandev, wandev_conf_t *conf)
 		break;
 #endif
 	default:
-		printk(KERN_ERR "%s: this firmware is not supported!\n",
-				wandev->name);
+		pr_err("%s: this firmware is not supported!\n", wandev->name);
 		rc = -EINVAL;
 	}
 
@@ -288,8 +286,7 @@ static int cycx_wan_shutdown(struct wan_device *wandev)
 	card = wandev->private;
 	wandev->state = WAN_UNCONFIGURED;
 	cycx_down(&card->hw);
-	printk(KERN_INFO "%s: irq %d being freed!\n", wandev->name,
-			wandev->irq);
+	pr_info("%s: irq %d being freed!\n", wandev->name, wandev->irq);
 	free_irq(wandev->irq, card);
 out:	return ret;
 }
@@ -308,8 +305,8 @@ static irqreturn_t cycx_isr(int irq, void *dev_id)
 		goto out;
 
 	if (card->in_isr) {
-		printk(KERN_WARNING "%s: interrupt re-entrancy on IRQ %d!\n",
-				    card->devname, card->wandev.irq);
+		pr_warn("%s: interrupt re-entrancy on IRQ %d!\n",
+			card->devname, card->wandev.irq);
 		goto out;
 	}
 
@@ -337,7 +334,7 @@ void cycx_set_state(struct cycx_device *card, int state)
 			string_state = "disconnected!";
 			break;
 		}
-		printk(KERN_INFO "%s: link %s\n", card->devname, string_state);
+		pr_info("%s: link %s\n", card->devname, string_state);
 		card->wandev.state = state;
 	}
 
diff --git a/drivers/net/wan/cycx_x25.c b/drivers/net/wan/cycx_x25.c
index cf9e15f..06f3f63 100644
--- a/drivers/net/wan/cycx_x25.c
+++ b/drivers/net/wan/cycx_x25.c
@@ -76,6 +76,8 @@
 * 1998/08/08	acme		Initial version.
 */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #define CYCLOMX_X25_DEBUG 1
 
 #include <linux/ctype.h>	/* isdigit() */
@@ -230,8 +232,8 @@ int cycx_x25_wan_init(struct cycx_device *card, wandev_conf_t *conf)
 
 	/* Verify configuration ID */
 	if (conf->config_id != WANCONFIG_X25) {
-		printk(KERN_INFO "%s: invalid configuration ID %u!\n",
-				 card->devname, conf->config_id);
+		pr_info("%s: invalid configuration ID %u!\n",
+			card->devname, conf->config_id);
 		return -EINVAL;
 	}
 
@@ -374,8 +376,7 @@ static int cycx_wan_new_if(struct wan_device *wandev, struct net_device *dev,
 	int err = 0;
 
 	if (!conf->name[0] || strlen(conf->name) > WAN_IFNAME_SZ) {
-		printk(KERN_INFO "%s: invalid interface name!\n",
-		       card->devname);
+		pr_info("%s: invalid interface name!\n", card->devname);
 		return -EINVAL;
 	}
 
@@ -398,8 +399,8 @@ static int cycx_wan_new_if(struct wan_device *wandev, struct net_device *dev,
 
 		if (len) {
 			if (len > WAN_ADDRESS_SZ) {
-				printk(KERN_ERR "%s: %s local addr too long!\n",
-						wandev->name, chan->name);
+				pr_err("%s: %s local addr too long!\n",
+				       wandev->name, chan->name);
 				err = -EINVAL;
 				goto error;
 			} else {
@@ -429,15 +430,14 @@ static int cycx_wan_new_if(struct wan_device *wandev, struct net_device *dev,
 		if (lcn >= card->u.x.lo_pvc && lcn <= card->u.x.hi_pvc)
 			chan->lcn = lcn;
 		else {
-			printk(KERN_ERR
-				"%s: PVC %u is out of range on interface %s!\n",
-				wandev->name, lcn, chan->name);
+			pr_err("%s: PVC %u is out of range on interface %s!\n",
+			       wandev->name, lcn, chan->name);
 			err = -EINVAL;
 			goto error;
 		}
 	} else {
-		printk(KERN_ERR "%s: invalid media address on interface %s!\n",
-				wandev->name, chan->name);
+		pr_err("%s: invalid media address on interface %s!\n",
+		       wandev->name, chan->name);
 		err = -EINVAL;
 		goto error;
 	}
@@ -607,9 +607,8 @@ static netdev_tx_t cycx_netdevice_hard_start_xmit(struct sk_buff *skb,
 		++chan->ifstats.tx_dropped;
 	else if (chan->svc && chan->protocol &&
 		 chan->protocol != ntohs(skb->protocol)) {
-		printk(KERN_INFO
-		       "%s: unsupported Ethertype 0x%04X on interface %s!\n",
-		       card->devname, ntohs(skb->protocol), dev->name);
+		pr_info("%s: unsupported Ethertype 0x%04X on interface %s!\n",
+			card->devname, ntohs(skb->protocol), dev->name);
 		++chan->ifstats.tx_errors;
 	} else if (chan->protocol == ETH_P_IP) {
 		switch (chan->state) {
@@ -643,9 +642,8 @@ static netdev_tx_t cycx_netdevice_hard_start_xmit(struct sk_buff *skb,
 			cycx_x25_chan_disconnect(dev);
 			goto free_packet;
 	        default:
-			printk(KERN_INFO
-			       "%s: unknown %d x25-iface request on %s!\n",
-			       card->devname, skb->data[0], dev->name);
+			pr_info("%s: unknown %d x25-iface request on %s!\n",
+				card->devname, skb->data[0], dev->name);
 			++chan->ifstats.tx_errors;
 			goto free_packet;
 		}
@@ -746,8 +744,7 @@ static void cycx_x25_irq_tx(struct cycx_device *card, struct cycx_x25_cmd *cmd)
 		card->buff_int_mode_unbusy = 1;
 		netif_wake_queue(dev);
 	} else
-		printk(KERN_ERR "%s:ackvc for inexistent lcn %d\n",
-				 card->devname, lcn);
+		pr_err("%s:ackvc for inexistent lcn %d\n", card->devname, lcn);
 }
 
 /* Receive interrupt handler.
@@ -780,8 +777,8 @@ static void cycx_x25_irq_rx(struct cycx_device *card, struct cycx_x25_cmd *cmd)
 	dev = cycx_x25_get_dev_by_lcn(wandev, lcn);
 	if (!dev) {
 		/* Invalid channel, discard packet */
-		printk(KERN_INFO "%s: receiving on orphaned LCN %d!\n",
-				 card->devname, lcn);
+		pr_info("%s: receiving on orphaned LCN %d!\n",
+			card->devname, lcn);
 		return;
 	}
 
@@ -802,8 +799,8 @@ static void cycx_x25_irq_rx(struct cycx_device *card, struct cycx_x25_cmd *cmd)
 		if ((skb = dev_alloc_skb((chan->protocol == ETH_P_X25 ? 1 : 0) +
 					 bufsize +
 					 dev->hard_header_len)) == NULL) {
-			printk(KERN_INFO "%s: no socket buffers available!\n",
-					 card->devname);
+			pr_info("%s: no socket buffers available!\n",
+				card->devname);
 			chan->drop_sequence = 1;
 			++chan->ifstats.rx_dropped;
 			return;
@@ -826,8 +823,8 @@ static void cycx_x25_irq_rx(struct cycx_device *card, struct cycx_x25_cmd *cmd)
 		if (bitm)
 			chan->drop_sequence = 1;
 
-		printk(KERN_INFO "%s: unexpectedly long packet sequence "
-			"on interface %s!\n", card->devname, dev->name);
+		pr_info("%s: unexpectedly long packet sequence on interface %s!\n",
+			card->devname, dev->name);
 		++chan->ifstats.rx_length_errors;
 		return;
 	}
@@ -880,8 +877,8 @@ static void cycx_x25_irq_connect(struct cycx_device *card,
 	dev = cycx_x25_get_dev_by_dte_addr(wandev, rem);
 	if (!dev) {
 		/* Invalid channel, discard packet */
-		printk(KERN_INFO "%s: connect not expected: remote %s!\n",
-				 card->devname, rem);
+		pr_info("%s: connect not expected: remote %s!\n",
+			card->devname, rem);
 		return;
 	}
 
@@ -909,8 +906,8 @@ static void cycx_x25_irq_connect_confirm(struct cycx_device *card,
 	if (!dev) {
 		/* Invalid channel, discard packet */
 		clear_bit(--key, (void*)&card->u.x.connection_keys);
-		printk(KERN_INFO "%s: connect confirm not expected: lcn %d, "
-				 "key=%d!\n", card->devname, lcn, key);
+		pr_info("%s: connect confirm not expected: lcn %d, key=%d!\n",
+			card->devname, lcn, key);
 		return;
 	}
 
@@ -934,8 +931,8 @@ static void cycx_x25_irq_disconnect_confirm(struct cycx_device *card,
 	dev = cycx_x25_get_dev_by_lcn(wandev, lcn);
 	if (!dev) {
 		/* Invalid channel, discard packet */
-		printk(KERN_INFO "%s:disconnect confirm not expected!:lcn %d\n",
-				 card->devname, lcn);
+		pr_info("%s:disconnect confirm not expected!:lcn %d\n",
+			card->devname, lcn);
 		return;
 	}
 
@@ -980,13 +977,13 @@ static void cycx_x25_irq_log(struct cycx_device *card, struct cycx_x25_cmd *cmd)
 	cycx_peek(&card->hw, cmd->buf + 10 + toread, &code, 1);
 	cycx_peek(&card->hw, cmd->buf + 10 + toread + 1, &routine, 1);
 
-	printk(KERN_INFO "cycx_x25_irq_handler: X25_LOG (0x4500) indic.:\n");
-	printk(KERN_INFO "cmd->buf=0x%X\n", cmd->buf);
-	printk(KERN_INFO "Log message code=0x%X\n", msg_code);
-	printk(KERN_INFO "Link=%d\n", link);
-	printk(KERN_INFO "log code=0x%X\n", code);
-	printk(KERN_INFO "log routine=0x%X\n", routine);
-	printk(KERN_INFO "Message size=%d\n", size);
+	pr_info("cycx_x25_irq_handler: X25_LOG (0x4500) indic.:\n");
+	pr_info("cmd->buf=0x%X\n", cmd->buf);
+	pr_info("Log message code=0x%X\n", msg_code);
+	pr_info("Link=%d\n", link);
+	pr_info("log code=0x%X\n", code);
+	pr_info("log routine=0x%X\n", routine);
+	pr_info("Message size=%d\n", size);
 	hex_dump("Message", bf, toread);
 #endif
 }
@@ -1009,24 +1006,14 @@ static void cycx_x25_irq_stat(struct cycx_device *card,
 static void cycx_x25_irq_spurious(struct cycx_device *card,
 				  struct cycx_x25_cmd *cmd)
 {
-	printk(KERN_INFO "%s: spurious interrupt (0x%X)!\n",
-			 card->devname, cmd->command);
+	pr_info("%s: spurious interrupt (0x%X)!\n",
+		card->devname, cmd->command);
 }
 #ifdef CYCLOMX_X25_DEBUG
 static void hex_dump(char *msg, unsigned char *p, int len)
 {
-	unsigned char hex[1024],
-	    	* phex = hex;
-
-	if (len >= (sizeof(hex) / 2))
-		len = (sizeof(hex) / 2) - 1;
-
-	while (len--) {
-		sprintf(phex, "%02x", *p++);
-		phex += 2;
-	}
-
-	printk(KERN_INFO "%s: %s\n", msg, hex);
+	print_hex_dump(KERN_INFO, msg, DUMP_PREFIX_OFFSET, 16, 1,
+		       p, len, true);
 }
 #endif
 
@@ -1203,8 +1190,8 @@ static int x25_place_call(struct cycx_device *card,
 	u8 key;
 
 	if (card->u.x.connection_keys == ~0U) {
-		printk(KERN_INFO "%s: too many simultaneous connection "
-				 "requests!\n", card->devname);
+		pr_info("%s: too many simultaneous connection requests!\n",
+			card->devname);
 		return -EAGAIN;
 	}
 
@@ -1381,8 +1368,8 @@ static void cycx_x25_chan_timer(unsigned long d)
 	if (chan->state == WAN_CONNECTED)
 		cycx_x25_chan_disconnect(dev);
 	else
-		printk(KERN_ERR "%s: %s for svc (%s) not connected!\n",
-				chan->card->devname, __func__, dev->name);
+		pr_err("%s: %s for svc (%s) not connected!\n",
+		       chan->card->devname, __func__, dev->name);
 }
 
 /* Set logical channel state. */
@@ -1433,8 +1420,8 @@ static void cycx_x25_set_chan_state(struct net_device *dev, u8 state)
 			break;
 		}
 
-		printk(KERN_INFO "%s: interface %s %s\n", card->devname,
-				  dev->name, string_state);
+		pr_info("%s: interface %s %s\n",
+			card->devname, dev->name, string_state);
 		chan->state = state;
 	}
 
@@ -1488,7 +1475,7 @@ static void cycx_x25_chan_send_event(struct net_device *dev, u8 event)
 	unsigned char *ptr;
 
 	if ((skb = dev_alloc_skb(1)) == NULL) {
-		printk(KERN_ERR "%s: out of memory\n", __func__);
+		pr_err("%s: out of memory\n", __func__);
 		return;
 	}
 
@@ -1557,56 +1544,56 @@ static void reset_timer(struct net_device *dev)
 #ifdef CYCLOMX_X25_DEBUG
 static void cycx_x25_dump_config(struct cycx_x25_config *conf)
 {
-	printk(KERN_INFO "X.25 configuration\n");
-	printk(KERN_INFO "-----------------\n");
-	printk(KERN_INFO "link number=%d\n", conf->link);
-	printk(KERN_INFO "line speed=%d\n", conf->speed);
-	printk(KERN_INFO "clock=%sternal\n", conf->clock == 8 ? "Ex" : "In");
-	printk(KERN_INFO "# level 2 retransm.=%d\n", conf->n2);
-	printk(KERN_INFO "level 2 window=%d\n", conf->n2win);
-	printk(KERN_INFO "level 3 window=%d\n", conf->n3win);
-	printk(KERN_INFO "# logical channels=%d\n", conf->nvc);
-	printk(KERN_INFO "level 3 pkt len=%d\n", conf->pktlen);
-	printk(KERN_INFO "my address=%d\n", conf->locaddr);
-	printk(KERN_INFO "remote address=%d\n", conf->remaddr);
-	printk(KERN_INFO "t1=%d seconds\n", conf->t1);
-	printk(KERN_INFO "t2=%d seconds\n", conf->t2);
-	printk(KERN_INFO "t21=%d seconds\n", conf->t21);
-	printk(KERN_INFO "# PVCs=%d\n", conf->npvc);
-	printk(KERN_INFO "t23=%d seconds\n", conf->t23);
-	printk(KERN_INFO "flags=0x%x\n", conf->flags);
+	pr_info("X.25 configuration\n");
+	pr_info("-----------------\n");
+	pr_info("link number=%d\n", conf->link);
+	pr_info("line speed=%d\n", conf->speed);
+	pr_info("clock=%sternal\n", conf->clock == 8 ? "Ex" : "In");
+	pr_info("# level 2 retransm.=%d\n", conf->n2);
+	pr_info("level 2 window=%d\n", conf->n2win);
+	pr_info("level 3 window=%d\n", conf->n3win);
+	pr_info("# logical channels=%d\n", conf->nvc);
+	pr_info("level 3 pkt len=%d\n", conf->pktlen);
+	pr_info("my address=%d\n", conf->locaddr);
+	pr_info("remote address=%d\n", conf->remaddr);
+	pr_info("t1=%d seconds\n", conf->t1);
+	pr_info("t2=%d seconds\n", conf->t2);
+	pr_info("t21=%d seconds\n", conf->t21);
+	pr_info("# PVCs=%d\n", conf->npvc);
+	pr_info("t23=%d seconds\n", conf->t23);
+	pr_info("flags=0x%x\n", conf->flags);
 }
 
 static void cycx_x25_dump_stats(struct cycx_x25_stats *stats)
 {
-	printk(KERN_INFO "X.25 statistics\n");
-	printk(KERN_INFO "--------------\n");
-	printk(KERN_INFO "rx_crc_errors=%d\n", stats->rx_crc_errors);
-	printk(KERN_INFO "rx_over_errors=%d\n", stats->rx_over_errors);
-	printk(KERN_INFO "n2_tx_frames=%d\n", stats->n2_tx_frames);
-	printk(KERN_INFO "n2_rx_frames=%d\n", stats->n2_rx_frames);
-	printk(KERN_INFO "tx_timeouts=%d\n", stats->tx_timeouts);
-	printk(KERN_INFO "rx_timeouts=%d\n", stats->rx_timeouts);
-	printk(KERN_INFO "n3_tx_packets=%d\n", stats->n3_tx_packets);
-	printk(KERN_INFO "n3_rx_packets=%d\n", stats->n3_rx_packets);
-	printk(KERN_INFO "tx_aborts=%d\n", stats->tx_aborts);
-	printk(KERN_INFO "rx_aborts=%d\n", stats->rx_aborts);
+	pr_info("X.25 statistics\n");
+	pr_info("--------------\n");
+	pr_info("rx_crc_errors=%d\n", stats->rx_crc_errors);
+	pr_info("rx_over_errors=%d\n", stats->rx_over_errors);
+	pr_info("n2_tx_frames=%d\n", stats->n2_tx_frames);
+	pr_info("n2_rx_frames=%d\n", stats->n2_rx_frames);
+	pr_info("tx_timeouts=%d\n", stats->tx_timeouts);
+	pr_info("rx_timeouts=%d\n", stats->rx_timeouts);
+	pr_info("n3_tx_packets=%d\n", stats->n3_tx_packets);
+	pr_info("n3_rx_packets=%d\n", stats->n3_rx_packets);
+	pr_info("tx_aborts=%d\n", stats->tx_aborts);
+	pr_info("rx_aborts=%d\n", stats->rx_aborts);
 }
 
 static void cycx_x25_dump_devs(struct wan_device *wandev)
 {
 	struct net_device *dev = wandev->dev;
 
-	printk(KERN_INFO "X.25 dev states\n");
-	printk(KERN_INFO "name: addr:           txoff:  protocol:\n");
-	printk(KERN_INFO "---------------------------------------\n");
+	pr_info("X.25 dev states\n");
+	pr_info("name: addr:           txoff:  protocol:\n");
+	pr_info("---------------------------------------\n");
 
 	while(dev) {
 		struct cycx_x25_channel *chan = netdev_priv(dev);
 
-		printk(KERN_INFO "%-5.5s %-15.15s   %d     ETH_P_%s\n",
-				 chan->name, chan->addr, netif_queue_stopped(dev),
-				 chan->protocol == ETH_P_IP ? "IP" : "X25");
+		pr_info("%-5.5s %-15.15s   %d     ETH_P_%s\n",
+			chan->name, chan->addr, netif_queue_stopped(dev),
+			chan->protocol == ETH_P_IP ? "IP" : "X25");
 		dev = chan->slave;
 	}
 }
-- 
1.7.6.rc1
