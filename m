From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [patch 4/8 2.5] e1000 Check value returned by from pci_enable_device
Date: Fri, 17 Sep 2004 02:57:41 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0409170233040.15233-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: ganesh.venkatesan@intel.com, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up linux-2.5/drivers/net/e1000/e1000_ethtool.c linux-2.5/drivers/net/e1000.new/e1000_ethtool.c
--- linux-2.5/drivers/net/e1000/e1000_ethtool.c	2004-09-09 11:17:11.000000000 -0700
+++ linux-2.5/drivers/net/e1000.new/e1000_ethtool.c	2004-09-09 11:17:12.000000000 -0700
@@ -1017,8 +1017,8 @@ e1000_setup_desc_rings(struct e1000_adap
 		struct e1000_rx_desc *rx_desc = E1000_RX_DESC(*rxdr, i);
 		struct sk_buff *skb;
 
-		if(!(skb = alloc_skb(E1000_RXBUFFER_2048 + NET_IP_ALIGN,
-				     GFP_KERNEL))) {
+		if(!(skb = alloc_skb(E1000_RXBUFFER_2048 + NET_IP_ALIGN, 
+				GFP_KERNEL))) {
 			ret_val = 6;
 			goto err_nomem;
 		}
diff -up linux-2.5/drivers/net/e1000/e1000_main.c linux-2.5/drivers/net/e1000.new/e1000_main.c
--- linux-2.5/drivers/net/e1000/e1000_main.c	2004-09-09 11:17:11.000000000 -0700
+++ linux-2.5/drivers/net/e1000.new/e1000_main.c	2004-09-09 11:17:12.000000000 -0700
@@ -2881,9 +2881,9 @@ e1000_resume(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev->priv;
-	uint32_t manc;
+	uint32_t manc, ret;
 
-	pci_enable_device(pdev);
+	ret = pci_enable_device(pdev);
 	pci_set_power_state(pdev, 0);
 	pci_restore_state(pdev, adapter->pci_state);
 
