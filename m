From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [patch 2/8 2.5] e1000 - Removed support for advanced TCO features
Date: Fri, 17 Sep 2004 02:57:13 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0409170230370.15233-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: ganesh.venkatesan@intel.com, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up linux-2.5/drivers/net/e1000/e1000_main.c linux-2.5/drivers/net/e1000.new/e1000_main.c
--- linux-2.5/drivers/net/e1000/e1000_main.c	2004-09-09 11:17:11.000000000 -0700
+++ linux-2.5/drivers/net/e1000.new/e1000_main.c	2004-09-09 11:17:12.000000000 -0700
@@ -311,7 +311,8 @@ e1000_down(struct e1000_adapter *adapter
 void
 e1000_reset(struct e1000_adapter *adapter)
 {
-	uint32_t pba, manc;
+	uint32_t pba;
+
 	/* Repartition Pba for greater than 9k mtu
 	 * To take effect CTRL.RST is required.
 	 */
@@ -354,12 +355,6 @@ e1000_reset(struct e1000_adapter *adapte
 
 	e1000_reset_adaptive(&adapter->hw);
 	e1000_phy_get_info(&adapter->hw, &adapter->phy_info);
-
-	if(adapter->en_mng_pt) {
-		manc = E1000_READ_REG(&adapter->hw, MANC);
-		manc |= (E1000_MANC_ARP_EN | E1000_MANC_EN_MNG2HOST);
-		E1000_WRITE_REG(&adapter->hw, MANC, manc);
-	}
 }
 
 /**
@@ -498,8 +503,6 @@ e1000_probe(struct pci_dev *pdev,
  	/* hard_start_xmit is safe against parallel locking */
  	netdev->features |= NETIF_F_LLTX; 
  
-	adapter->en_mng_pt = e1000_enable_mng_pass_thru(&adapter->hw);
-
 	/* before reading the EEPROM, reset the controller to 
 	 * put the device in a known good starting state */
 	
