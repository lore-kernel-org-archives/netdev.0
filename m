From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2] et131x: Promote staging et131x driver to drivers/net
Date: Tue, 23 Sep 2014 14:07:17 -0700
Message-ID: <1411506437.29268.13.camel@joe-AO725>
References: <1411421283-25073-1-git-send-email-mark.einon@gmail.com>
 <1411502723-4628-1-git-send-email-mark.einon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, angus@agibson.me, gregkh@linuxfoundation.org,
 linux-kernel@vger.kernel.org, netdev@vger.kernel.org, davem@davemloft.net
To: Mark Einon <mark.einon@gmail.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1411502723-4628-1-git-send-email-mark.einon@gmail.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On Tue, 2014-09-23 at 21:05 +0100, Mark Einon wrote:
> This patch moves the et131x gigabit ethernet driver from drivers/staging
> to drivers/net/ethernet/agere.

checkpatch type modification you might consider:

Reduce logging line count by consolidating repeated dev_warn
Use ether_addr_copy
Line wrapping for 80 columns
Remove unnecessary parentheses
Remove unnecessary OOM message

---
 drivers/staging/et131x/et131x.c | 51 ++++++++++++++++-------------------------
 1 file changed, 20 insertions(+), 31 deletions(-)

diff --git a/drivers/staging/et131x/et131x.c b/drivers/staging/et131x/et131x.c
index eefa9f1..3aaedc9 100644
--- a/drivers/staging/et131x/et131x.c
+++ b/drivers/staging/et131x/et131x.c
@@ -1294,9 +1294,8 @@ static int et131x_phy_mii_read(struct et131x_adapter *adapter, u8 addr,
 	/* If we hit the max delay, we could not read the register */
 	if (delay == 50) {
 		dev_warn(&adapter->pdev->dev,
-			 "reg 0x%08x could not be read\n", reg);
-		dev_warn(&adapter->pdev->dev, "status is  0x%08x\n",
-			 mii_indicator);
+			 "reg 0x%08x could not be read - status is 0x%08x\n",
+			 reg, mii_indicator);
 
 		status = -EIO;
 		goto out;
@@ -1371,11 +1370,8 @@ static int et131x_mii_write(struct et131x_adapter *adapter, u8 addr, u8 reg,
 		u16 tmp;
 
 		dev_warn(&adapter->pdev->dev,
-			 "reg 0x%08x could not be written", reg);
-		dev_warn(&adapter->pdev->dev, "status is  0x%08x\n",
-			 mii_indicator);
-		dev_warn(&adapter->pdev->dev, "command is  0x%08x\n",
-			 readl(&mac->mii_mgmt_cmd));
+			 "reg 0x%08x could not be written - status is 0x%08x - command is 0x%08x\n",
+			 reg, mii_indicator, readl(&mac->mii_mgmt_cmd));
 
 		et131x_mii_read(adapter, reg, &tmp);
 
@@ -2444,10 +2440,8 @@ static struct rfd *nic_rx_pkts(struct et131x_adapter *adapter)
 	rfd->len = len;
 
 	skb = dev_alloc_skb(rfd->len + 2);
-	if (!skb) {
-		dev_err(&adapter->pdev->dev, "Couldn't alloc an SKB for Rx\n");
+	if (!skb)
 		return NULL;
-	}
 
 	adapter->netdev->stats.rx_bytes += rfd->len;
 
@@ -2661,7 +2655,7 @@ static int nic_send_packet(struct et131x_adapter *adapter, struct tcb *tcb)
 				desc[frag].len_vlan = skb_headlen(skb) / 2;
 				dma_addr = dma_map_single(&adapter->pdev->dev,
 							  skb->data,
-							  (skb_headlen(skb) / 2),
+							  skb_headlen(skb) / 2,
 							  DMA_TO_DEVICE);
 				desc[frag].addr_lo = lower_32_bits(dma_addr);
 				desc[frag].addr_hi = upper_32_bits(dma_addr);
@@ -2670,8 +2664,8 @@ static int nic_send_packet(struct et131x_adapter *adapter, struct tcb *tcb)
 				desc[frag].len_vlan = skb_headlen(skb) / 2;
 				dma_addr = dma_map_single(&adapter->pdev->dev,
 							  skb->data +
-							  (skb_headlen(skb) / 2),
-							  (skb_headlen(skb) / 2),
+							  skb_headlen(skb) / 2,
+							  skb_headlen(skb) / 2,
 							  DMA_TO_DEVICE);
 				desc[frag].addr_lo = lower_32_bits(dma_addr);
 				desc[frag].addr_hi = upper_32_bits(dma_addr);
@@ -3212,15 +3206,13 @@ static void et131x_hwaddr_init(struct et131x_adapter *adapter)
 		 * working with so we need to copy the current
 		 * address into the permanent address
 		 */
-		memcpy(adapter->rom_addr,
-		       adapter->addr, ETH_ALEN);
+		ether_addr_copy(adapter->rom_addr, adapter->addr);
 	} else {
 		/* We do not have an override address, so set the
 		 * current address to the permanent address and add
 		 * it to the device
 		 */
-		memcpy(adapter->addr,
-		       adapter->rom_addr, ETH_ALEN);
+		ether_addr_copy(adapter->addr, adapter->rom_addr);
 	}
 }
 
@@ -3415,7 +3407,8 @@ static void et131x_adjust_link(struct net_device *netdev)
 			et131x_mii_read(adapter, PHY_MPHY_CONTROL_REG,
 					&register18);
 			et131x_mii_write(adapter, phydev->addr,
-					 PHY_MPHY_CONTROL_REG, register18 | 0x4);
+					 PHY_MPHY_CONTROL_REG,
+					 register18 | 0x4);
 			et131x_mii_write(adapter, phydev->addr, PHY_INDEX_REG,
 					 register18 | 0x8402);
 			et131x_mii_write(adapter, phydev->addr, PHY_DATA_REG,
@@ -3448,7 +3441,8 @@ static void et131x_adjust_link(struct net_device *netdev)
 			et131x_mii_read(adapter, PHY_MPHY_CONTROL_REG,
 					&register18);
 			et131x_mii_write(adapter, phydev->addr,
-					 PHY_MPHY_CONTROL_REG, register18 | 0x4);
+					 PHY_MPHY_CONTROL_REG,
+					 register18 | 0x4);
 			et131x_mii_write(adapter, phydev->addr,
 					 PHY_INDEX_REG, register18 | 0x8402);
 			et131x_mii_write(adapter, phydev->addr,
@@ -3778,8 +3772,7 @@ static irqreturn_t et131x_isr(int irq, void *dev_id)
 		 */
 		/* TRAP();*/
 
-		dev_warn(&adapter->pdev->dev,
-			 "RxDMA_ERR interrupt, error %x\n",
+		dev_warn(&adapter->pdev->dev, "RxDMA_ERR interrupt, error %x\n",
 			 readl(&iomem->txmac.tx_test));
 	}
 
@@ -3805,8 +3798,7 @@ static irqreturn_t et131x_isr(int irq, void *dev_id)
 		 * occur. In a nutshell, the whole Tx path will have to be reset
 		 * and re-configured afterwards.
 		 */
-		dev_warn(&adapter->pdev->dev,
-			 "TXMAC interrupt, error 0x%08x\n",
+		dev_warn(&adapter->pdev->dev, "TXMAC interrupt, error 0x%08x\n",
 			 err);
 
 		/* If we are debugging, we want to see this error, otherwise we
@@ -3823,11 +3815,8 @@ static irqreturn_t et131x_isr(int irq, void *dev_id)
 		/* MP_SET_FLAG( adapter, FMP_ADAPTER_HARDWARE_ERROR); */
 
 		dev_warn(&adapter->pdev->dev,
-			 "RXMAC interrupt, error 0x%08x.  Requesting reset\n",
+			 "RXMAC interrupt, error 0x%08x - requesting reset - Enable 0x%08x, Diag 0x%08x\n",
 			 readl(&iomem->rxmac.err_reg));
-
-		dev_warn(&adapter->pdev->dev,
-			 "Enable 0x%08x, Diag 0x%08x\n",
 			 readl(&iomem->rxmac.ctrl),
 			 readl(&iomem->rxmac.rxq_diag));
 
@@ -4081,7 +4070,7 @@ static void et131x_multicast(struct net_device *netdev)
 	netdev_for_each_mc_addr(ha, netdev) {
 		if (i == NIC_MAX_MCAST_LIST)
 			break;
-		memcpy(adapter->multicast_list[i++], ha->addr, ETH_ALEN);
+		ether_addr_copy(adapter->multicast_list[i++], ha->addr);
 	}
 	adapter->multicast_addr_count = i;
 
@@ -4211,7 +4200,7 @@ static int et131x_change_mtu(struct net_device *netdev, int new_mtu)
 	et131x_init_send(adapter);
 
 	et131x_hwaddr_init(adapter);
-	memcpy(netdev->dev_addr, adapter->addr, ETH_ALEN);
+	ether_addr_copy(netdev->dev_addr, adapter->addr);
 
 	/* Init the device with the new settings */
 	et131x_adapter_setup(adapter);
@@ -4329,7 +4318,7 @@ static int et131x_pci_setup(struct pci_dev *pdev,
 	netif_napi_add(netdev, &adapter->napi, et131x_poll, 64);
 
 	/* Copy address into the net_device struct */
-	memcpy(netdev->dev_addr, adapter->addr, ETH_ALEN);
+	ether_addr_copy(netdev->dev_addr, adapter->addr);
 
 	rc = -ENOMEM;
