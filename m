From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: [e1000 netdev-2.6 3/6] Serial-over-LAN (SoL) fix
Date: Mon, 2 Feb 2004 14:01:40 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0402021346140.6288-100000@localhost.localdomain>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, "Feldman, Scott" <scott.feldman@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


* Set VLAN filtering to IEEE 802.1Q after reset so we don't
  break Serial-over-LAN (SoL) connections that use VLANs.

-----------------

diff -Naurp netdev-2.6/drivers/net/e1000/e1000_main.c netdev-2.6/drivers/net/e1000.mod/e1000_main.c
--- netdev-2.6/drivers/net/e1000/e1000_main.c	2004-02-02 12:08:24.000000000 -0800
+++ netdev-2.6/drivers/net/e1000.mod/e1000_main.c	2004-02-02 12:09:00.000000000 -0800
@@ -339,6 +339,10 @@ e1000_reset(struct e1000_adapter *adapte
 	if(adapter->hw.mac_type >= e1000_82544)
 		E1000_WRITE_REG(&adapter->hw, WUC, 0);
 	e1000_init_hw(&adapter->hw);
+
+	/* Enable h/w to recognize an 802.1Q VLAN Ethernet packet */
+	E1000_WRITE_REG(&adapter->hw, VET, ETHERNET_IEEE_VLAN_TYPE);
+
 	e1000_reset_adaptive(&adapter->hw);
 	e1000_phy_get_info(&adapter->hw, &adapter->phy_info);
 }
@@ -2666,8 +2670,6 @@ e1000_vlan_rx_register(struct net_device
 	if(grp) {
 		/* enable VLAN tag insert/strip */
 
-		E1000_WRITE_REG(&adapter->hw, VET, ETHERNET_IEEE_VLAN_TYPE);
-
 		ctrl = E1000_READ_REG(&adapter->hw, CTRL);
 		ctrl |= E1000_CTRL_VME;
 		E1000_WRITE_REG(&adapter->hw, CTRL, ctrl);
