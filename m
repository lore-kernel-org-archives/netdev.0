From: Xose Vazquez Perez <xose@wanadoo.es>
Subject: Re: [PATCH] tg3, more IDs
Date: Sat, 06 Dec 2003 19:03:38 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FD219FA.5010908@wanadoo.es>
References: <3FD20895.2020605@wanadoo.es>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000005030202000100050105"
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com,
        "David S. Miller"
 <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000005030202000100050105
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Xose Vazquez Perez wrote:

> two new IDs for tg3:

> 0x14e4,0x1649 is a BCM5704S based board.
> 0x14e4,0x166e is a BCM5705F based board.

forget my last patch, here goes one more complete:

- adds two new IDs:
0x14e4,0x1649 - BCM5704S based board.
0x14e4,0x166e - BCM5705F based board.

- in subsys_id_to_phy_id:
replaced BCM_ID magical numbers with MACROS
added one IBM board
deleted imcompatible COMPAQ boards

- 5705F limited to 10/100 too.

And as side note, Broadcom has enabled _by default_ TSO in
its latest driver 7.1.9(11/03/2003).
For curious people: http://www.broadcom.com/drivers/downloaddrivers.php

-thanks-


--------------000005030202000100050105
Content-Type: text/plain;
 name="tg3_patch.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="tg3_patch.diff"

--- linux/drivers/net/tg3.c	2003-12-06 17:44:05.000000000 +0100
+++ n/drivers/net/tg3.c	2003-12-06 18:34:59.000000000 +0100
@@ -175,6 +175,10 @@
 	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
 	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5901_2,
 	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
+	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5704S_2,
+	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
+	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5705F,
+	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
 	{ PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_9DXX,
 	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
 	{ PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_9MXX,
@@ -6401,25 +6405,22 @@
 
 static struct subsys_tbl_ent subsys_id_to_phy_id[] = {
 	/* Broadcom boards. */
-	{ 0x14e4, 0x1644, PHY_ID_BCM5401 }, /* BCM95700A6 */
-	{ 0x14e4, 0x0001, PHY_ID_BCM5701 }, /* BCM95701A5 */
-	{ 0x14e4, 0x0002, PHY_ID_BCM8002 }, /* BCM95700T6 */
-	{ 0x14e4, 0x0003, PHY_ID_SERDES  }, /* BCM95700A9 */
-	{ 0x14e4, 0x0005, PHY_ID_BCM5701 }, /* BCM95701T1 */
-	{ 0x14e4, 0x0006, PHY_ID_BCM5701 }, /* BCM95701T8 */
-	{ 0x14e4, 0x0007, PHY_ID_SERDES  }, /* BCM95701A7 */
-	{ 0x14e4, 0x0008, PHY_ID_BCM5701 }, /* BCM95701A10 */
-	{ 0x14e4, 0x8008, PHY_ID_BCM5701 }, /* BCM95701A12 */
-	{ 0x14e4, 0x0009, PHY_ID_BCM5701 }, /* BCM95703Ax1 */
-	{ 0x14e4, 0x8009, PHY_ID_BCM5701 }, /* BCM95703Ax2 */
+	{ PCI_VENDOR_ID_BROADCOM, 0x1644, PHY_ID_BCM5401 }, /* BCM95700A6 */
+	{ PCI_VENDOR_ID_BROADCOM, 0x0001, PHY_ID_BCM5701 }, /* BCM95701A5 */
+	{ PCI_VENDOR_ID_BROADCOM, 0x0002, PHY_ID_BCM8002 }, /* BCM95700T6 */
+	{ PCI_VENDOR_ID_BROADCOM, 0x0003, PHY_ID_SERDES  }, /* BCM95700A9 */
+	{ PCI_VENDOR_ID_BROADCOM, 0x0005, PHY_ID_BCM5701 }, /* BCM95701T1 */
+	{ PCI_VENDOR_ID_BROADCOM, 0x0006, PHY_ID_BCM5701 }, /* BCM95701T8 */
+	{ PCI_VENDOR_ID_BROADCOM, 0x0007, PHY_ID_SERDES  }, /* BCM95701A7 */
+	{ PCI_VENDOR_ID_BROADCOM, 0x0008, PHY_ID_BCM5701 }, /* BCM95701A10 */
+	{ PCI_VENDOR_ID_BROADCOM, 0x8008, PHY_ID_BCM5701 }, /* BCM95701A12 */
+	{ PCI_VENDOR_ID_BROADCOM, 0x0009, PHY_ID_BCM5701 }, /* BCM95703Ax1 */
+	{ PCI_VENDOR_ID_BROADCOM, 0x8009, PHY_ID_BCM5701 }, /* BCM95703Ax2 */
 
 	/* 3com boards. */
 	{ PCI_VENDOR_ID_3COM, 0x1000, PHY_ID_BCM5401 }, /* 3C996T */
 	{ PCI_VENDOR_ID_3COM, 0x1006, PHY_ID_BCM5701 }, /* 3C996BT */
-	/* { PCI_VENDOR_ID_3COM, 0x1002, PHY_ID_XXX },     3C996CT */
-	/* { PCI_VENDOR_ID_3COM, 0x1003, PHY_ID_XXX },     3C997T */
 	{ PCI_VENDOR_ID_3COM, 0x1004, PHY_ID_SERDES  }, /* 3C996SX */
-	/* { PCI_VENDOR_ID_3COM, 0x1005, PHY_ID_XXX },     3C997SZ */
 	{ PCI_VENDOR_ID_3COM, 0x1007, PHY_ID_BCM5701 }, /* 3C1000T */
 	{ PCI_VENDOR_ID_3COM, 0x1008, PHY_ID_BCM5701 }, /* 3C940BR01 */
 
@@ -6434,7 +6435,10 @@
 	{ PCI_VENDOR_ID_COMPAQ, 0x009a, PHY_ID_BCM5701 }, /* BANSHEE_2 */
 	{ PCI_VENDOR_ID_COMPAQ, 0x007d, PHY_ID_SERDES  }, /* CHANGELING */
 	{ PCI_VENDOR_ID_COMPAQ, 0x0085, PHY_ID_BCM5701 }, /* NC7780 */
-	{ PCI_VENDOR_ID_COMPAQ, 0x0099, PHY_ID_BCM5701 }  /* NC7780_2 */
+	{ PCI_VENDOR_ID_COMPAQ, 0x0099, PHY_ID_BCM5701 }, /* NC7780_2 */
+
+	/* IBM boards. */
+	{ PCI_VENDOR_ID_IBM, 0x0281, PHY_ID_SERDES } /* IBM??? */
 };
 
 static int __devinit tg3_phy_probe(struct tg3 *tp)
@@ -6974,7 +6978,8 @@
 	    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705 &&
 	     tp->pdev->vendor == PCI_VENDOR_ID_BROADCOM &&
 	     (tp->pdev->device == PCI_DEVICE_ID_TIGON3_5901 ||
-	      tp->pdev->device == PCI_DEVICE_ID_TIGON3_5901_2)))
+	      tp->pdev->device == PCI_DEVICE_ID_TIGON3_5901_2 ||
+	      tp->pdev->device == PCI_DEVICE_ID_TIGON3_5705F)))
 		tp->tg3_flags |= TG3_FLAG_10_100_ONLY;
 
 	err = tg3_phy_probe(tp);
--- linux/include/linux/pci_ids.h	2003-12-06 17:44:05.000000000 +0100
+++ n/include/linux/pci_ids.h	2003-12-06 17:30:10.000000000 +0100
@@ -1656,11 +1656,13 @@
 #define PCI_DEVICE_ID_TIGON3_5702	0x1646
 #define PCI_DEVICE_ID_TIGON3_5703	0x1647
 #define PCI_DEVICE_ID_TIGON3_5704	0x1648
+#define PCI_DEVICE_ID_TIGON3_5704S_2	0x1649
 #define PCI_DEVICE_ID_TIGON3_5702FE	0x164d
 #define PCI_DEVICE_ID_TIGON3_5705	0x1653
 #define PCI_DEVICE_ID_TIGON3_5705_2	0x1654
 #define PCI_DEVICE_ID_TIGON3_5705M	0x165d
 #define PCI_DEVICE_ID_TIGON3_5705M_2	0x165e
+#define PCI_DEVICE_ID_TIGON3_5705F	0x166e
 #define PCI_DEVICE_ID_TIGON3_5782	0x1696
 #define PCI_DEVICE_ID_TIGON3_5788	0x169c
 #define PCI_DEVICE_ID_TIGON3_5702X	0x16a6


--------------000005030202000100050105--
