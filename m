From: ganesh.venkatesan@intel.com
Subject: [PATCH 2/12 2.5] e1000 - Enable TSO
Date: Thu, 29 Jul 2004 08:31:41 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0407290757530.21929-100000@westville2.jf.intel.com>
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
@@ -476,7 +476,6 @@ e1000_probe(struct pci_dev *pdev,
 	}
 
 #ifdef NETIF_F_TSO
-#ifdef BROKEN_ON_NON_IA_ARCHS
 	/* Disbaled for now until root-cause is found for
 	 * hangs reported against non-IA archs.  TSO can be
 	 * enabled using ethtool -K eth<x> tso on */
@@ -484,11 +483,10 @@ e1000_probe(struct pci_dev *pdev,
 	   (adapter->hw.mac_type != e1000_82547))
 		netdev->features |= NETIF_F_TSO;
 #endif
-#endif
-
 	if(pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 
+
 	adapter->en_mng_pt = e1000_enable_mng_pass_thru(&adapter->hw);
 
 	/* before reading the EEPROM, reset the controller to 
