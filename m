From: Joe Perches <joe@perches.com>
Subject: [PATCH wireless-next 04/20] atmel: atmel_cs: Use pr_<level>
Date: Thu, 14 Jun 2012 22:53:44 -0700
Message-ID: <ce3d70d9120108bf646e4a3c0c8b5698ce3ce1ad.1339739416.git.joe@perches.com>
References: <cover.1339739415.git.joe@perches.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Simon Kelley <simon@thekelleys.org.uk>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1339739415.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use a more current logging style.

Convert printks to pr_<level>.
Coalesce formats, align arguments.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/atmel.c    |   71 ++++++++++++++++++++-------------------
 drivers/net/wireless/atmel_cs.c |    4 ++-
 2 files changed, 39 insertions(+), 36 deletions(-)

diff --git a/drivers/net/wireless/atmel.c b/drivers/net/wireless/atmel.c
index d07c030..2688735 100644
--- a/drivers/net/wireless/atmel.c
+++ b/drivers/net/wireless/atmel.c
@@ -39,6 +39,8 @@
 
 ******************************************************************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/init.h>
 #include <linux/interrupt.h>
 
@@ -1189,7 +1191,7 @@ static irqreturn_t service_interrupt(int irq, void *dev_id)
 	while (1) {
 		if (!atmel_lock_mac(priv)) {
 			/* failed to contact card */
-			printk(KERN_ALERT "%s: failed to contact MAC.\n", dev->name);
+			pr_alert("%s: failed to contact MAC\n", dev->name);
 			return IRQ_HANDLED;
 		}
 
@@ -1209,7 +1211,7 @@ static irqreturn_t service_interrupt(int irq, void *dev_id)
 
 		if (!atmel_lock_mac(priv)) {
 			/* failed to contact card */
-			printk(KERN_ALERT "%s: failed to contact MAC.\n", dev->name);
+			pr_alert("%s: failed to contact MAC\n", dev->name);
 			return IRQ_HANDLED;
 		}
 
@@ -1240,7 +1242,8 @@ static irqreturn_t service_interrupt(int irq, void *dev_id)
 			break;
 
 		case ISR_FATAL_ERROR:
-			printk(KERN_ALERT "%s: *** FATAL error interrupt ***\n", dev->name);
+			pr_alert("%s: *** FATAL error interrupt ***\n",
+				 dev->name);
 			atmel_enter_state(priv, STATION_STATE_MGMT_ERROR);
 			break;
 
@@ -1256,7 +1259,7 @@ static irqreturn_t service_interrupt(int irq, void *dev_id)
 				build_wpa_mib(priv);
 			break;
 		case ISR_GENERIC_IRQ:
-			printk(KERN_INFO "%s: Generic_irq received.\n", dev->name);
+			pr_info("%s: Generic_irq received\n", dev->name);
 			break;
 		}
 	}
@@ -1355,7 +1358,8 @@ int atmel_open(struct net_device *dev)
 				break;
 		if (i == ARRAY_SIZE(channel_table)) {
 			priv->reg_domain = REG_DOMAIN_MKK1;
-			printk(KERN_ALERT "%s: failed to get regulatory domain: assuming MKK1.\n", dev->name);
+			pr_alert("%s: failed to get regulatory domain: assuming MKK1\n",
+				 dev->name);
 		}
 	}
 
@@ -1536,7 +1540,7 @@ struct net_device *init_atmel_card(unsigned short irq, unsigned long port,
 		return NULL;
 
 	if (dev_alloc_name(dev, dev->name) < 0) {
-		printk(KERN_ERR "atmel: Couldn't get name!\n");
+		pr_err("Couldn't get name!\n");
 		goto err_out_free;
 	}
 
@@ -1611,7 +1615,8 @@ struct net_device *init_atmel_card(unsigned short irq, unsigned long port,
 	SET_NETDEV_DEV(dev, sys_dev);
 
 	if ((rc = request_irq(dev->irq, service_interrupt, IRQF_SHARED, dev->name, dev))) {
-		printk(KERN_ERR "%s: register interrupt %d failed, rc %d\n", dev->name, irq, rc);
+		pr_err("%s: register interrupt %d failed, rc %d\n",
+		       dev->name, irq, rc);
 		goto err_out_free;
 	}
 
@@ -1632,10 +1637,10 @@ struct net_device *init_atmel_card(unsigned short irq, unsigned long port,
 
 	ent = create_proc_read_entry ("driver/atmel", 0, NULL, atmel_read_proc, priv);
 	if (!ent)
-		printk(KERN_WARNING "atmel: unable to create /proc entry.\n");
+		pr_warn("unable to create /proc entry\n");
 
-	printk(KERN_INFO "%s: Atmel at76c50x. Version %d.%d. MAC %pM\n",
-	       dev->name, DRIVER_MAJOR, DRIVER_MINOR, dev->dev_addr);
+	pr_info("%s: Atmel at76c50x. Version %d.%d. MAC %pM\n",
+		dev->name, DRIVER_MAJOR, DRIVER_MINOR, dev->dev_addr);
 
 	return dev;
 
@@ -3642,12 +3647,12 @@ static int atmel_wakeup_firmware(struct atmel_private *priv)
 	}
 
 	if (i == 0) {
-		printk(KERN_ALERT "%s: MAC failed to boot.\n", priv->dev->name);
+		pr_alert("%s: MAC failed to boot\n", priv->dev->name);
 		return -EIO;
 	}
 
 	if ((priv->host_info_base = atmel_read16(priv->dev, MR2)) == 0xffff) {
-		printk(KERN_ALERT "%s: card missing.\n", priv->dev->name);
+		pr_alert("%s: card missing\n", priv->dev->name);
 		return -ENODEV;
 	}
 
@@ -3670,20 +3675,19 @@ static int atmel_wakeup_firmware(struct atmel_private *priv)
 	}
 
 	if (i == 0) {
-		printk(KERN_ALERT "%s: MAC failed to initialise.\n",
-				priv->dev->name);
+		pr_alert("%s: MAC failed to initialise\n", priv->dev->name);
 		return -EIO;
 	}
 
 	/* Check for MAC_INIT_OK only on the register that the MAC_INIT_OK was set */
 	if ((mr3 & MAC_INIT_COMPLETE) &&
 	    !(atmel_read16(priv->dev, MR3) & MAC_INIT_OK)) {
-		printk(KERN_ALERT "%s: MAC failed MR3 self-test.\n", priv->dev->name);
+		pr_alert("%s: MAC failed MR3 self-test\n", priv->dev->name);
 		return -EIO;
 	}
 	if ((mr1 & MAC_INIT_COMPLETE) &&
 	    !(atmel_read16(priv->dev, MR1) & MAC_INIT_OK)) {
-		printk(KERN_ALERT "%s: MAC failed MR1 self-test.\n", priv->dev->name);
+		pr_alert("%s: MAC failed MR1 self-test\n", priv->dev->name);
 		return -EIO;
 	}
 
@@ -3735,7 +3739,8 @@ static int probe_atmel_card(struct net_device *dev)
 			if (atmel_read16(dev, MR3) & MAC_BOOT_COMPLETE)
 				break;
 		if (i == 0) {
-			printk(KERN_ALERT "%s: MAC failed to boot MAC address reader.\n", dev->name);
+			pr_alert("%s: MAC failed to boot MAC address reader\n",
+				 dev->name);
 		} else {
 			atmel_copy_to_host(dev, dev->dev_addr, atmel_read16(dev, MR2), 6);
 			/* got address, now squash it again until the network
@@ -3773,7 +3778,8 @@ static int probe_atmel_card(struct net_device *dev)
 			static const u8 default_mac[] = {
 				0x00, 0x04, 0x25, 0x00, 0x00, 0x00
 			};
-			printk(KERN_ALERT "%s: *** Invalid MAC address. UPGRADE Firmware ****\n", dev->name);
+			pr_alert("%s: *** Invalid MAC address. UPGRADE Firmware ****\n",
+				 dev->name);
 			memcpy(dev->dev_addr, default_mac, 6);
 		}
 	}
@@ -3926,19 +3932,16 @@ static int reset_atmel_card(struct net_device *dev)
 		if (!(fw = priv->firmware)) {
 			if (priv->firmware_type == ATMEL_FW_TYPE_NONE) {
 				if (strlen(priv->firmware_id) == 0) {
-					printk(KERN_INFO
-					       "%s: card type is unknown: assuming at76c502 firmware is OK.\n",
-					       dev->name);
-					printk(KERN_INFO
-					       "%s: if not, use the firmware= module parameter.\n",
-					       dev->name);
+					pr_info("%s: card type is unknown: assuming at76c502 firmware is OK\n",
+						dev->name);
+					pr_info("%s: if not, use the firmware= module parameter\n",
+						dev->name);
 					strcpy(priv->firmware_id, "atmel_at76c502.bin");
 				}
 				err = request_firmware(&fw_entry, priv->firmware_id, priv->sys_dev);
 				if (err != 0) {
-					printk(KERN_ALERT
-					       "%s: firmware %s is missing, cannot continue.\n",
-					       dev->name, priv->firmware_id);
+					pr_alert("%s: firmware %s is missing, cannot continue\n",
+						 dev->name, priv->firmware_id);
 					return err;
 				}
 			} else {
@@ -3964,9 +3967,8 @@ static int reset_atmel_card(struct net_device *dev)
 					}
 				}
 				if (!success) {
-					printk(KERN_ALERT
-					       "%s: firmware %s is missing, cannot start.\n",
-					       dev->name, priv->firmware_id);
+					pr_alert("%s: firmware %s is missing, cannot start\n",
+						 dev->name, priv->firmware_id);
 					priv->firmware_id[0] = '\0';
 					return -ENOENT;
 				}
@@ -4035,8 +4037,7 @@ static int reset_atmel_card(struct net_device *dev)
 	if (!priv->radio_on_broken) {
 		if (atmel_send_command_wait(priv, CMD_EnableRadio, NULL, 0) ==
 		    CMD_STATUS_REJECTED_RADIO_OFF) {
-			printk(KERN_INFO "%s: cannot turn the radio on.\n",
-			       dev->name);
+			pr_info("%s: cannot turn the radio on\n", dev->name);
 			return -EIO;
 		}
 	}
@@ -4101,7 +4102,7 @@ static int atmel_send_command_wait(struct atmel_private *priv, int command,
 	}
 
 	if (i == 0) {
-		printk(KERN_ALERT "%s: failed to contact MAC.\n", priv->dev->name);
+		pr_alert("%s: failed to contact MAC\n", priv->dev->name);
 		status =  CMD_STATUS_HOST_ERROR;
 	} else {
 		if (command != CMD_EnableRadio)
@@ -4155,7 +4156,7 @@ static void atmel_set_mib(struct atmel_private *priv, u8 type, u8 index,
 	m.index = index;
 
 	if (data_len > MIB_MAX_DATA_BYTES)
-		printk(KERN_ALERT "%s: MIB buffer too small.\n", priv->dev->name);
+		pr_alert("%s: MIB buffer too small\n", priv->dev->name);
 
 	memcpy(m.data, data, data_len);
 	atmel_send_command_wait(priv, CMD_Set_MIB_Vars, &m, MIB_HEADER_SIZE + data_len);
@@ -4170,7 +4171,7 @@ static void atmel_get_mib(struct atmel_private *priv, u8 type, u8 index,
 	m.index = index;
 
 	if (data_len > MIB_MAX_DATA_BYTES)
-		printk(KERN_ALERT "%s: MIB buffer too small.\n", priv->dev->name);
+		pr_alert("%s: MIB buffer too small\n", priv->dev->name);
 
 	atmel_send_command_wait(priv, CMD_Get_MIB_Vars, &m, MIB_HEADER_SIZE + data_len);
 	atmel_copy_to_host(priv->dev, data,
diff --git a/drivers/net/wireless/atmel_cs.c b/drivers/net/wireless/atmel_cs.c
index ded03d2..2b85420 100644
--- a/drivers/net/wireless/atmel_cs.c
+++ b/drivers/net/wireless/atmel_cs.c
@@ -29,6 +29,8 @@
 
 ******************************************************************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #ifdef __IN_PCMCIA_PACKAGE__
 #include <pcmcia/k_compat.h>
 #endif
@@ -80,7 +82,7 @@ static int atmel_probe(struct pcmcia_device *p_dev)
 	/* Allocate space for private device-specific data */
 	local = kzalloc(sizeof(local_info_t), GFP_KERNEL);
 	if (!local) {
-		printk(KERN_ERR "atmel_cs: no memory for new device\n");
+		pr_err("no memory for new device\n");
 		return -ENOMEM;
 	}
 	p_dev->priv = local;
-- 
1.7.8.111.gad25c.dirty
