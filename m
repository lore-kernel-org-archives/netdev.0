From: ganesh.venkatesan@intel.com
Subject: [PATCH 10/12 2.5] e1000 - more DPRINTK messages to syslog
Date: Thu, 29 Jul 2004 08:32:49 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0407290814540.21929-100000@westville2.jf.intel.com>
Reply-To: ganesh.venkatesan@intel.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <ganesh.venkatesan@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up linux-2.5/drivers/net/e1000/e1000_main.c linux-2.5/drivers/net/e1000.new/e1000_main.c
--- linux-2.5/drivers/net/e1000/e1000_main.c	2004-07-28 21:50:08.672461176 -0700
+++ linux-2.5/drivers/net/e1000.new/e1000_main.c	2004-07-28 21:50:09.523331824 -0700
@@ -347,7 +347,8 @@ e1000_reset(struct e1000_adapter *adapte
 	e1000_reset_hw(&adapter->hw);
 	if(adapter->hw.mac_type >= e1000_82544)
 		E1000_WRITE_REG(&adapter->hw, WUC, 0);
-	e1000_init_hw(&adapter->hw);
+	if(e1000_init_hw(&adapter->hw))
+		DPRINTK(PROBE, ERR, "Hardware Error\n");
 
 	/* Enable h/w to recognize an 802.1Q VLAN Ethernet packet */
 	E1000_WRITE_REG(&adapter->hw, VET, ETHERNET_IEEE_VLAN_TYPE);
@@ -517,10 +518,12 @@ e1000_probe(struct pci_dev *pdev,
 
 	/* copy the MAC address out of the EEPROM */
 
-	e1000_read_mac_addr(&adapter->hw);
+	if (e1000_read_mac_addr(&adapter->hw))
+		DPRINTK(PROBE, ERR, "EEPROM Read Error\n");
 	memcpy(netdev->dev_addr, adapter->hw.mac_addr, netdev->addr_len);
 
 	if(!is_valid_ether_addr(netdev->dev_addr)) {
+		DPRINTK(PROBE, ERR, "Invalid MAC Address\n");
 		err = -EIO;
 		goto err_eeprom;
 	}
@@ -801,6 +789,8 @@ e1000_setup_tx_resources(struct e1000_ad
 	size = sizeof(struct e1000_buffer) * txdr->count;
 	txdr->buffer_info = vmalloc(size);
 	if(!txdr->buffer_info) {
+		DPRINTK(PROBE, ERR, 
+		"Unble to Allocate Memory for the Transmit descriptor ring\n");
 		return -ENOMEM;
 	}
 	memset(txdr->buffer_info, 0, size);
@@ -812,6 +802,8 @@ e1000_setup_tx_resources(struct e1000_ad
 
 	txdr->desc = pci_alloc_consistent(pdev, txdr->size, &txdr->dma);
 	if(!txdr->desc) {
+		DPRINTK(PROBE, ERR, 
+		"Unble to Allocate Memory for the Transmit descriptor ring\n");
 		vfree(txdr->buffer_info);
 		return -ENOMEM;
 	}
@@ -918,6 +906,8 @@ e1000_setup_rx_resources(struct e1000_ad
 	size = sizeof(struct e1000_buffer) * rxdr->count;
 	rxdr->buffer_info = vmalloc(size);
 	if(!rxdr->buffer_info) {
+		DPRINTK(PROBE, ERR, 
+		"Unble to Allocate Memory for the Recieve descriptor ring\n");
 		return -ENOMEM;
 	}
 	memset(rxdr->buffer_info, 0, size);
@@ -930,6 +920,8 @@ e1000_setup_rx_resources(struct e1000_ad
 	rxdr->desc = pci_alloc_consistent(pdev, rxdr->size, &rxdr->dma);
 
 	if(!rxdr->desc) {
+		DPRINTK(PROBE, ERR, 
+		"Unble to Allocate Memory for the Recieve descriptor ring\n");
 		vfree(rxdr->buffer_info);
 		return -ENOMEM;
 	}
@@ -2795,6 +2806,8 @@ e1000_set_spd_dplx(struct e1000_adapter 
 		break;
 	case SPEED_1000 + DUPLEX_HALF: /* not supported */
 	default:
+		DPRINTK(PROBE, ERR, 
+			"Unsupported Speed/Duplexity configuration\n");
 		return -EINVAL;
 	}
 	return 0;
