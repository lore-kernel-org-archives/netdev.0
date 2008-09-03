From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes for .26
Date: Wed, 3 Sep 2008 10:37:16 -0400
Message-ID: <20080903143716.GA29026@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756170AbYICOhh@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull from 'davem-fixes' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git davem-fixes

to receive the following updates:

 drivers/net/ixgbe/ixgbe_main.c       |    6 ++++++
 drivers/net/netxen/netxen_nic_main.c |   10 ----------
 drivers/net/pcmcia/axnet_cs.c        |    1 +
 drivers/net/pcmcia/pcnet_cs.c        |    2 +-
 drivers/net/usb/pegasus.c            |   11 ++++++-----
 5 files changed, 14 insertions(+), 16 deletions(-)

Andy Gospodarek (1):
      ixgbe: initialize interrupt throttle rate

David Brownell (1):
      net/usb/pegasus: avoid hundreds of diagnostics

Dhananjay Phadke (1):
      netxen: Remove workaround for chipset quirk

Komuro (1):
      pcnet-cs, axnet_cs: add new IDs, remove dup ID with less info

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 53f41b6..a417be7 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2304,6 +2304,12 @@ static int __devinit ixgbe_set_interrupt_capability(struct ixgbe_adapter
 	int vector, v_budget;
 
 	/*
+	 * Set the default interrupt throttle rate.
+	 */
+	adapter->rx_eitr = (1000000 / IXGBE_DEFAULT_ITR_RX_USECS);
+	adapter->tx_eitr = (1000000 / IXGBE_DEFAULT_ITR_TX_USECS);
+
+	/*
 	 * It's easy to be greedy for MSI-X vectors, but it really
 	 * doesn't do us much good if we have a lot more vectors
 	 * than CPU's.  So let's be conservative and only ask for
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 32bb47a..008fd66 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -359,16 +359,6 @@ static void netxen_pcie_strap_init(struct netxen_adapter *adapter)
 	int i, pos;
 	struct pci_dev *pdev;
 
-	pdev = pci_get_device(0x1166, 0x0140, NULL);
-	if (pdev) {
-		pci_dev_put(pdev);
-		adapter->hw_read_wx(adapter,
-			NETXEN_PCIE_REG(PCIE_TGT_SPLIT_CHICKEN), &chicken, 4);
-		chicken |= 0x4000;
-		adapter->hw_write_wx(adapter,
-			NETXEN_PCIE_REG(PCIE_TGT_SPLIT_CHICKEN), &chicken, 4);
-	}
-
 	pdev = adapter->pdev;
 
 	adapter->hw_read_wx(adapter,
diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index 3f682d4..52bf11b 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -784,6 +784,7 @@ static struct pcmcia_device_id axnet_ids[] = {
 	PCMCIA_DEVICE_PROD_ID12("corega K.K.", "corega FEther PCC-TXD", 0x5261440f, 0x436768c5),
 	PCMCIA_DEVICE_PROD_ID12("corega K.K.", "corega FEtherII PCC-TXD", 0x5261440f, 0x730df72e),
 	PCMCIA_DEVICE_PROD_ID12("Dynalink", "L100C16", 0x55632fd5, 0x66bc2a90),
+	PCMCIA_DEVICE_PROD_ID12("IO DATA", "ETXPCM", 0x547e66dc, 0x233adac2),
 	PCMCIA_DEVICE_PROD_ID12("Linksys", "EtherFast 10/100 PC Card (PCMPC100 V3)", 0x0733cc81, 0x232019a8),
 	PCMCIA_DEVICE_PROD_ID12("MELCO", "LPC3-TX", 0x481e0094, 0xf91af609),
 	PCMCIA_DEVICE_PROD_ID12("PCMCIA", "100BASE", 0x281f1c5d, 0x7c2add04),
diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
index 2d4c4ad..ebc1ae6 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -1626,6 +1626,7 @@ static struct pcmcia_device_id pcnet_ids[] = {
 	PCMCIA_DEVICE_PROD_ID12("corega K.K.", "corega EtherII PCC-TD", 0x5261440f, 0xc49bd73d),
 	PCMCIA_DEVICE_PROD_ID12("Corega K.K.", "corega EtherII PCC-TD", 0xd4fdcbd8, 0xc49bd73d),
 	PCMCIA_DEVICE_PROD_ID12("corega K.K.", "corega Ether PCC-T", 0x5261440f, 0x6705fcaa),
+	PCMCIA_DEVICE_PROD_ID12("corega K.K.", "corega Ether PCC-TD", 0x5261440f, 0x47d5ca83),
 	PCMCIA_DEVICE_PROD_ID12("corega K.K.", "corega FastEther PCC-TX", 0x5261440f, 0x485e85d9),
 	PCMCIA_DEVICE_PROD_ID12("Corega,K.K.", "Ethernet LAN Card", 0x110d26d9, 0x9fd2f0a2),
 	PCMCIA_DEVICE_PROD_ID12("corega,K.K.", "Ethernet LAN Card", 0x9791a90e, 0x9fd2f0a2),
@@ -1737,7 +1738,6 @@ static struct pcmcia_device_id pcnet_ids[] = {
 	PCMCIA_DEVICE_PROD_ID1("CyQ've 10 Base-T LAN CARD", 0x94faf360),
 	PCMCIA_DEVICE_PROD_ID1("EP-210 PCMCIA LAN CARD.", 0x8850b4de),
 	PCMCIA_DEVICE_PROD_ID1("ETHER-C16", 0x06a8514f),
-	PCMCIA_DEVICE_PROD_ID1("IC-CARD", 0x60cb09a6),
 	PCMCIA_DEVICE_PROD_ID1("NE2000 Compatible", 0x75b8ad5a),
 	PCMCIA_DEVICE_PROD_ID2("EN-6200P2", 0xa996d078),
 	/* too generic! */
diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
index a84ba48..8c19307 100644
--- a/drivers/net/usb/pegasus.c
+++ b/drivers/net/usb/pegasus.c
@@ -117,7 +117,7 @@ static void ctrl_callback(struct urb *urb)
 	case -ENOENT:
 		break;
 	default:
-		if (netif_msg_drv(pegasus))
+		if (netif_msg_drv(pegasus) && printk_ratelimit())
 			dev_dbg(&pegasus->intf->dev, "%s, status %d\n",
 				__FUNCTION__, urb->status);
 	}
@@ -166,7 +166,7 @@ static int get_registers(pegasus_t * pegasus, __u16 indx, __u16 size,
 		set_current_state(TASK_RUNNING);
 		if (ret == -ENODEV)
 			netif_device_detach(pegasus->net);
-		if (netif_msg_drv(pegasus))
+		if (netif_msg_drv(pegasus) && printk_ratelimit())
 			dev_err(&pegasus->intf->dev, "%s, status %d\n",
 					__FUNCTION__, ret);
 		goto out;
@@ -275,7 +275,7 @@ static int set_register(pegasus_t * pegasus, __u16 indx, __u8 data)
 	if ((ret = usb_submit_urb(pegasus->ctrl_urb, GFP_ATOMIC))) {
 		if (ret == -ENODEV)
 			netif_device_detach(pegasus->net);
-		if (netif_msg_drv(pegasus))
+		if (netif_msg_drv(pegasus) && printk_ratelimit())
 			dev_err(&pegasus->intf->dev, "%s, status %d\n",
 					__FUNCTION__, ret);
 		goto out;
@@ -1209,8 +1209,7 @@ static void pegasus_set_multicast(struct net_device *net)
 		pegasus->eth_regs[EthCtrl2] |= RX_PROMISCUOUS;
 		if (netif_msg_link(pegasus))
 			pr_info("%s: Promiscuous mode enabled.\n", net->name);
-	} else if (net->mc_count ||
-		   (net->flags & IFF_ALLMULTI)) {
+	} else if (net->mc_count || (net->flags & IFF_ALLMULTI)) {
 		pegasus->eth_regs[EthCtrl0] |= RX_MULTICAST;
 		pegasus->eth_regs[EthCtrl2] &= ~RX_PROMISCUOUS;
 		if (netif_msg_link(pegasus))
@@ -1220,6 +1219,8 @@ static void pegasus_set_multicast(struct net_device *net)
 		pegasus->eth_regs[EthCtrl2] &= ~RX_PROMISCUOUS;
 	}
 
+	pegasus->ctrl_urb->status = 0;
+
 	pegasus->flags |= ETH_REGS_CHANGE;
 	ctrl_callback(pegasus->ctrl_urb);
 }
