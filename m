From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: [e1000 2.6 3/11] Turn off ASF support on Fiber nics
Date: Mon, 8 Sep 2003 20:14:17 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309081849000.1261-100000@localhost.localdomain>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


* Turn off ASF support on fiber nics.  Wasn't tested and isn't
  known to work, so disable before someone hurts themselves.

----------------

diff -Nuarp linux-2.6.0-test4/drivers/net/e1000/e1000_main.c linux-2.6.0-test4/drivers/net/e1000.new/e1000_main.c
--- linux-2.6.0-test4/drivers/net/e1000/e1000_main.c	2003-08-22 16:54:23.000000000 -0700
+++ linux-2.6.0-test4/drivers/net/e1000.new/e1000_main.c	2003-09-08 09:13:11.000000000 -0700
@@ -534,7 +534,8 @@ e1000_remove(struct pci_dev *pdev)
 	struct e1000_adapter *adapter = netdev->priv;
 	uint32_t manc;
 
-	if(adapter->hw.mac_type >= e1000_82540) {
+	if(adapter->hw.mac_type >= e1000_82540 &&
+	   adapter->hw.media_type == e1000_media_type_copper) {
 		manc = E1000_READ_REG(&adapter->hw, MANC);
 		if(manc & E1000_MANC_SMBUS_EN) {
 			manc |= E1000_MANC_ARP_EN;
@@ -2797,7 +2798,8 @@ e1000_suspend(struct pci_dev *pdev, uint
 
 	pci_save_state(pdev, adapter->pci_state);
 
-	if(adapter->hw.mac_type >= e1000_82540) {
+	if(adapter->hw.mac_type >= e1000_82540 &&
+	   adapter->hw.media_type == e1000_media_type_copper) {
 		manc = E1000_READ_REG(&adapter->hw, MANC);
 		if(manc & E1000_MANC_SMBUS_EN) {
 			manc |= E1000_MANC_ARP_EN;
@@ -2835,7 +2837,8 @@ e1000_resume(struct pci_dev *pdev)
 
 	netif_device_attach(netdev);
 
-	if(adapter->hw.mac_type >= e1000_82540) {
+	if(adapter->hw.mac_type >= e1000_82540 &&
+	   adapter->hw.media_type == e1000_media_type_copper) {
 		manc = E1000_READ_REG(&adapter->hw, MANC);
 		manc &= ~(E1000_MANC_ARP_EN);
 		E1000_WRITE_REG(&adapter->hw, MANC, manc);
