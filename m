From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [PATCH net-drivers-2.4 8/10] e1000: Report failure code when loopback
 test fails
Date: Tue, 15 Feb 2005 13:35:49 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0502151147401.30336-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

8 Report failure code when loopback test fails
Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
diff -up net-drivers-2.4/drivers/net/e1000/e1000_ethtool.c net-drivers-2.4/drivers/net/e1000.new/e1000_ethtool.c
--- net-drivers-2.4/drivers/net/e1000/e1000_ethtool.c	2005-02-01 23:21:49.119102312 -0800
+++ net-drivers-2.4/drivers/net/e1000.new/e1000_ethtool.c	2005-02-01 23:21:50.368912312 -0800
@@ -1309,7 +1309,7 @@ e1000_run_loopback_test(struct e1000_ada
 	struct e1000_desc_ring *txdr = &adapter->test_tx_ring;
 	struct e1000_desc_ring *rxdr = &adapter->test_rx_ring;
 	struct pci_dev *pdev = adapter->pdev;
-	int i;
+	int i, ret_val;
 
 	E1000_WRITE_REG(&adapter->hw, RDT, rxdr->count - 1);
 
@@ -1329,11 +1331,12 @@ e1000_run_loopback_test(struct e1000_ada
 					    rxdr->buffer_info[i].length,
 					    PCI_DMA_FROMDEVICE);
 
-		if (!e1000_check_lbtest_frame(rxdr->buffer_info[i++].skb, 1024))
-			return 0;
-	} while (i < 64);
+		ret_val = e1000_check_lbtest_frame(rxdr->buffer_info[i].skb,
+						   1024);
+		i++;
+	} while (ret_val != 0 && i < 64);
 
-	return 13;
+	return ret_val;
 }
 
 static int
	
