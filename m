From: Joe Perches <joe@perches.com>
Subject: [PATCH 4/8] frame relay dlci/frad: Update to current logging forms
Date: Sun, 26 Jun 2011 22:01:31 -0700
Message-ID: <640f3aa3a6a954563769d9f3de090f9573b75ef6.1309150684.git.joe@perches.com>
References: <cover.1309150683.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, Mike McLagan <mike.mclagan@linux.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1309150683.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use pr_fmt, pr_<level> and netdev_<level> as appropriate.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wan/dlci.c |   22 +++++++++++++------
 drivers/net/wan/sdla.c |   52 +++++++++++++++++++++++++++--------------------
 2 files changed, 45 insertions(+), 29 deletions(-)

diff --git a/drivers/net/wan/dlci.c b/drivers/net/wan/dlci.c
index 21b104d..48ab38a 100644
--- a/drivers/net/wan/dlci.c
+++ b/drivers/net/wan/dlci.c
@@ -28,6 +28,8 @@
  *		2 of the License, or (at your option) any later version.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/types.h>
@@ -112,8 +114,7 @@ static void dlci_receive(struct sk_buff *skb, struct net_device *dev)
 
 	dlp = netdev_priv(dev);
 	if (!pskb_may_pull(skb, sizeof(*hdr))) {
-		printk(KERN_NOTICE "%s: invalid data no header\n",
-		       dev->name);
+		netdev_notice(dev, "invalid data no header\n");
 		dev->stats.rx_errors++;
 		kfree_skb(skb);
 		return;
@@ -126,7 +127,8 @@ static void dlci_receive(struct sk_buff *skb, struct net_device *dev)
 
 	if (hdr->control != FRAD_I_UI)
 	{
-		printk(KERN_NOTICE "%s: Invalid header flag 0x%02X.\n", dev->name, hdr->control);
+		netdev_notice(dev, "Invalid header flag 0x%02X\n",
+			      hdr->control);
 		dev->stats.rx_errors++;
 	}
 	else
@@ -135,14 +137,18 @@ static void dlci_receive(struct sk_buff *skb, struct net_device *dev)
 			case FRAD_P_PADDING:
 				if (hdr->NLPID != FRAD_P_SNAP)
 				{
-					printk(KERN_NOTICE "%s: Unsupported NLPID 0x%02X.\n", dev->name, hdr->NLPID);
+					netdev_notice(dev, "Unsupported NLPID 0x%02X\n",
+						      hdr->NLPID);
 					dev->stats.rx_errors++;
 					break;
 				}
 	 
 				if (hdr->OUI[0] + hdr->OUI[1] + hdr->OUI[2] != 0)
 				{
-					printk(KERN_NOTICE "%s: Unsupported organizationally unique identifier 0x%02X-%02X-%02X.\n", dev->name, hdr->OUI[0], hdr->OUI[1], hdr->OUI[2]);
+					netdev_notice(dev, "Unsupported organizationally unique identifier 0x%02X-%02X-%02X\n",
+						      hdr->OUI[0],
+						      hdr->OUI[1],
+						      hdr->OUI[2]);
 					dev->stats.rx_errors++;
 					break;
 				}
@@ -163,12 +169,14 @@ static void dlci_receive(struct sk_buff *skb, struct net_device *dev)
 			case FRAD_P_SNAP:
 			case FRAD_P_Q933:
 			case FRAD_P_CLNP:
-				printk(KERN_NOTICE "%s: Unsupported NLPID 0x%02X.\n", dev->name, hdr->pad);
+				netdev_notice(dev, "Unsupported NLPID 0x%02X\n",
+					      hdr->pad);
 				dev->stats.rx_errors++;
 				break;
 
 			default:
-				printk(KERN_NOTICE "%s: Invalid pad byte 0x%02X.\n", dev->name, hdr->pad);
+				netdev_notice(dev, "Invalid pad byte 0x%02X\n",
+					      hdr->pad);
 				dev->stats.rx_errors++;
 				break;				
 		}
diff --git a/drivers/net/wan/sdla.c b/drivers/net/wan/sdla.c
index 3f4e2b5..c853161 100644
--- a/drivers/net/wan/sdla.c
+++ b/drivers/net/wan/sdla.c
@@ -32,6 +32,8 @@
  *		2 of the License, or (at your option) any later version.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/types.h>
@@ -350,24 +352,24 @@ static void sdla_errors(struct net_device *dev, int cmd, int dlci, int ret, int
 		case SDLA_RET_MODEM:
 			state = data;
 			if (*state & SDLA_MODEM_DCD_LOW)
-				printk(KERN_INFO "%s: Modem DCD unexpectedly low!\n", dev->name);
+				netdev_info(dev, "Modem DCD unexpectedly low!\n");
 			if (*state & SDLA_MODEM_CTS_LOW)
-				printk(KERN_INFO "%s: Modem CTS unexpectedly low!\n", dev->name);
+				netdev_info(dev, "Modem CTS unexpectedly low!\n");
 			/* I should probably do something about this! */
 			break;
 
 		case SDLA_RET_CHANNEL_OFF:
-			printk(KERN_INFO "%s: Channel became inoperative!\n", dev->name);
+			netdev_info(dev, "Channel became inoperative!\n");
 			/* same here */
 			break;
 
 		case SDLA_RET_CHANNEL_ON:
-			printk(KERN_INFO "%s: Channel became operative!\n", dev->name);
+			netdev_info(dev, "Channel became operative!\n");
 			/* same here */
 			break;
 
 		case SDLA_RET_DLCI_STATUS:
-			printk(KERN_INFO "%s: Status change reported by Access Node.\n", dev->name);
+			netdev_info(dev, "Status change reported by Access Node\n");
 			len /= sizeof(struct _dlci_stat);
 			for(pstatus = data, i=0;i < len;i++,pstatus++)
 			{
@@ -382,29 +384,32 @@ static void sdla_errors(struct net_device *dev, int cmd, int dlci, int ret, int
 					sprintf(line, "unknown status: %02X", pstatus->flags);
 					state = line;
 				}
-				printk(KERN_INFO "%s: DLCI %i: %s.\n", dev->name, pstatus->dlci, state);
+				netdev_info(dev, "DLCI %i: %s\n",
+					    pstatus->dlci, state);
 				/* same here */
 			}
 			break;
 
 		case SDLA_RET_DLCI_UNKNOWN:
-			printk(KERN_INFO "%s: Received unknown DLCIs:", dev->name);
+			netdev_info(dev, "Received unknown DLCIs:");
 			len /= sizeof(short);
 			for(pdlci = data,i=0;i < len;i++,pdlci++)
-				printk(" %i", *pdlci);
-			printk("\n");
+				pr_cont(" %i", *pdlci);
+			pr_cont("\n");
 			break;
 
 		case SDLA_RET_TIMEOUT:
-			printk(KERN_ERR "%s: Command timed out!\n", dev->name);
+			netdev_err(dev, "Command timed out!\n");
 			break;
 
 		case SDLA_RET_BUF_OVERSIZE:
-			printk(KERN_INFO "%s: Bc/CIR overflow, acceptable size is %i\n", dev->name, len);
+			netdev_info(dev, "Bc/CIR overflow, acceptable size is %i\n",
+				    len);
 			break;
 
 		case SDLA_RET_BUF_TOO_BIG:
-			printk(KERN_INFO "%s: Buffer size over specified max of %i\n", dev->name, len);
+			netdev_info(dev, "Buffer size over specified max of %i\n",
+				    len);
 			break;
 
 		case SDLA_RET_CHANNEL_INACTIVE:
@@ -415,7 +420,8 @@ static void sdla_errors(struct net_device *dev, int cmd, int dlci, int ret, int
 				break;
 
 		default: 
-			printk(KERN_DEBUG "%s: Cmd 0x%2.2X generated return code 0x%2.2X\n", dev->name, cmd, ret);
+			netdev_dbg(dev, "Cmd 0x%02X generated return code 0x%02X\n",
+				   cmd, ret);
 			/* Further processing could be done here */
 			break;
 	}
@@ -678,12 +684,14 @@ static netdev_tx_t sdla_transmit(struct sk_buff *skb,
 		case ARPHRD_FRAD:
 			if (skb->dev->type != ARPHRD_DLCI)
 			{
-				printk(KERN_WARNING "%s: Non DLCI device, type %i, tried to send on FRAD module.\n", dev->name, skb->dev->type);
+				netdev_warn(dev, "Non DLCI device, type %i, tried to send on FRAD module\n",
+					    skb->dev->type);
 				accept = 0;
 			}
 			break;
 		default:
-			printk(KERN_WARNING "%s: unknown firmware type 0x%4.4X\n", dev->name, dev->type);
+			netdev_warn(dev, "unknown firmware type 0x%04X\n",
+				    dev->type);
 			accept = 0;
 			break;
 	}
@@ -807,7 +815,8 @@ static void sdla_receive(struct net_device *dev)
 
 		if (i == CONFIG_DLCI_MAX)
 		{
-			printk(KERN_NOTICE "%s: Received packet from invalid DLCI %i, ignoring.", dev->name, dlci);
+			netdev_notice(dev, "Received packet from invalid DLCI %i, ignoring\n",
+				      dlci);
 			dev->stats.rx_errors++;
 			success = 0;
 		}
@@ -819,7 +828,7 @@ static void sdla_receive(struct net_device *dev)
 		skb = dev_alloc_skb(len + sizeof(struct frhdr));
 		if (skb == NULL) 
 		{
-			printk(KERN_NOTICE "%s: Memory squeeze, dropping packet.\n", dev->name);
+			netdev_notice(dev, "Memory squeeze, dropping packet\n");
 			dev->stats.rx_dropped++;
 			success = 0;
 		}
@@ -880,8 +889,7 @@ static irqreturn_t sdla_isr(int dummy, void *dev_id)
 
 	if (!flp->initialized)
 	{
-		printk(KERN_WARNING "%s: irq %d for uninitialized device.\n",
-		       dev->name, dev->irq);
+		netdev_warn(dev, "irq %d for uninitialized device\n", dev->irq);
 		return IRQ_NONE;
 	}
 
@@ -901,7 +909,7 @@ static irqreturn_t sdla_isr(int dummy, void *dev_id)
 		case SDLA_INTR_TX:
 		case SDLA_INTR_COMPLETE:
 		case SDLA_INTR_TIMER:
-			printk(KERN_WARNING "%s: invalid irq flag 0x%02X.\n", dev->name, byte);
+			netdev_warn(dev, "invalid irq flag 0x%02X\n", byte);
 			break;
 	}
 
@@ -1347,7 +1355,7 @@ static int sdla_set_config(struct net_device *dev, struct ifmap *map)
 		return -EINVAL;
 
 	if (!request_region(map->base_addr, SDLA_IO_EXTENTS, dev->name)){
-		printk(KERN_WARNING "SDLA: io-port 0x%04lx in use\n", dev->base_addr);
+		pr_warn("io-port 0x%04lx in use\n", dev->base_addr);
 		return -EINVAL;
 	}
 	base = map->base_addr;
@@ -1412,7 +1420,7 @@ static int sdla_set_config(struct net_device *dev, struct ifmap *map)
 		}
 	}
 
-	printk(KERN_NOTICE "%s: Unknown card type\n", dev->name);
+	netdev_notice(dev, "Unknown card type\n");
 	err = -ENODEV;
 	goto fail;
 
-- 
1.7.6.rc1
