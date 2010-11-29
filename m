From: Joe Perches <joe@perches.com>
Subject: [PATCH 11/11] forcedeth: Use netdev_dbg for printk(KERN_DEBUG
Date: Mon, 29 Nov 2010 09:42:02 -0800
Message-ID: <512b5db10a8c3dcc97ed295f42567e8a01d4aae0.1291051316.git.joe@perches.com>
References: <cover.1291051316.git.joe@perches.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Szymon Janc <szymon@janc.net.pl>,
	=?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirqus@gmail.com>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1970 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754893Ab0K2RmQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Nov 2010 12:42:16 -0500
In-Reply-To: <cover.1291051316.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the normal debugging functions.
Print mac address when using random_ether_addr.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/forcedeth.c |   19 ++++++++++++-------
 1 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index c2945d6..cd2d72d 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -3407,7 +3407,8 @@ static irqreturn_t nv_nic_irq_tx(int foo, void *data)
 				mod_timer(&np->nic_poll, jiffies + POLL_WAIT);
 			}
 			spin_unlock_irqrestore(&np->lock, flags);
-			printk(KERN_DEBUG "%s: too many iterations (%d) in nv_nic_irq_tx.\n", dev->name, i);
+			netdev_dbg(dev, "%s: too many iterations (%d)\n",
+				   __func__, i);
 			break;
 		}
 
@@ -3522,7 +3523,8 @@ static irqreturn_t nv_nic_irq_rx(int foo, void *data)
 				mod_timer(&np->nic_poll, jiffies + POLL_WAIT);
 			}
 			spin_unlock_irqrestore(&np->lock, flags);
-			printk(KERN_DEBUG "%s: too many iterations (%d) in nv_nic_irq_rx.\n", dev->name, i);
+			netdev_dbg(dev, "%s: too many iterations (%d)\n",
+				   __func__, i);
 			break;
 		}
 	}
@@ -3586,7 +3588,8 @@ static irqreturn_t nv_nic_irq_other(int foo, void *data)
 				mod_timer(&np->nic_poll, jiffies + POLL_WAIT);
 			}
 			spin_unlock_irqrestore(&np->lock, flags);
-			printk(KERN_DEBUG "%s: too many iterations (%d) in nv_nic_irq_other.\n", dev->name, i);
+			netdev_dbg(dev, "%s: too many iterations (%d)\n",
+				   __func__, i);
 			break;
 		}
 
@@ -5463,7 +5466,9 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 		dev->dev_addr[4] = (np->orig_mac[0] >>  8) & 0xff;
 		dev->dev_addr[5] = (np->orig_mac[0] >>  0) & 0xff;
 		writel(txreg|NVREG_TRANSMITPOLL_MAC_ADDR_REV, base + NvRegTransmitPoll);
-		printk(KERN_DEBUG "nv_probe: set workaround bit for reversed mac addr\n");
+		dev_dbg(&pci_dev->dev,
+			"%s: set workaround bit for reversed mac addr\n",
+			__func__);
 	}
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
@@ -5473,11 +5478,11 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 		 * to 01:23:45:67:89:ab
 		 */
 		dev_err(&pci_dev->dev,
-			"Invalid MAC address detected: %pM\n",
+			"Invalid MAC address detected: %pM - Please complain to your hardware vendor.\n",
 			dev->dev_addr);
-		dev_err(&pci_dev->dev,
-			"Please complain to your hardware vendor. Switched to a random MAC address.\n");
 		random_ether_addr(dev->dev_addr);
+		dev_err(&pci_dev->dev,
+			"Using random MAC address: %pM\n", dev->dev_addr);
 	}
 
 	/* set mac address */
-- 
1.7.3.2.245.g03276.dirty

