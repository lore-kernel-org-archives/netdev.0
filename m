From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: [e1000 netdev-2.6 2/6] disable TSO for now
Date: Sat, 21 Feb 2004 23:11:40 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0402212308550.1228-100000@localhost.localdomain>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, "Feldman, Scott" <scott.feldman@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


* Disable TSO as default setting until some hangs/resets caused
  with TSO enabled are root-caused.  TSO can still be manually
  enabled using ethtool -K.

-------------

diff -Naurp netdev-2.6/drivers/net/e1000/e1000_main.c netdev-2.6/drivers/net/e1000.mod/e1000_main.c
--- netdev-2.6/drivers/net/e1000/e1000_main.c	2004-02-20 14:05:38.000000000 -0800
+++ netdev-2.6/drivers/net/e1000.mod/e1000_main.c	2004-02-20 14:07:02.000000000 -0800
@@ -474,10 +474,15 @@ e1000_probe(struct pci_dev *pdev,
 	}
 
 #ifdef NETIF_F_TSO
+#ifdef BROKEN_ON_NON_IA_ARCHS
+	/* Disbaled for now until root-cause is found for
+	 * hangs reported against non-IA archs.  TSO can be
+	 * enabled using ethtool -K eth<x> tso on */
 	if((adapter->hw.mac_type >= e1000_82544) &&
 	   (adapter->hw.mac_type != e1000_82547))
 		netdev->features |= NETIF_F_TSO;
 #endif
+#endif
 
 	if(pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
