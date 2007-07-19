From: "Steven J. Hill" <sjhill@realitydiluted.com>
Subject: [PATCH] Merge GT/MV642xx Support into MV643xx Driver [1/8]
Date: Wed, 18 Jul 2007 23:47:54 -0500
Message-ID: <469EECFA.1010704@realitydiluted.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigFF9D409EAAF9D8A60112DF74"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from real.realitydiluted.com ([66.43.201.61]:49739 "EHLO
	real.realitydiluted.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753607AbXGSFYk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 01:24:40 -0400
Received: from atlas.inter.net ([10.0.0.3])
	by real.realitydiluted.com with esmtp (Exim 4.67)
	(envelope-from <sjhill@realitydiluted.com>)
	id 1IBNxt-00066C-BB
	for netdev@vger.kernel.org; Wed, 18 Jul 2007 23:50:15 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigFF9D409EAAF9D8A60112DF74
Content-Type: multipart/mixed;
 boundary="------------040201090408000508060705"

This is a multi-part message in MIME format.
--------------040201090408000508060705
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

This first patch 642xx #defines to the 'include/linux/mv643xx.h' file.

Signed-off-by: Steven J. Hill <sjhill1@rockwellcollins.com>
---


--------------040201090408000508060705
Content-Type: text/x-patch;
 name="01-mv643xx-64260-linux-header.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline;
 filename="01-mv643xx-64260-linux-header.patch"

--- linux-2.6.22.1/include/linux/mv643xx.h	2007-05-10 15:16:24.000000000 =
-0500
+++ linux-2.6.22.1-rci/include/linux/mv643xx.h	2007-07-18 15:50:44.000000=
000 -0500
@@ -666,7 +666,11 @@
 #define MV643XX_ETH_SHARED_REGS_SIZE                                0x20=
00
=20
 #define MV643XX_ETH_PHY_ADDR_REG                                    0x20=
00
+#ifdef CONFIG_GT64260
+#define MV643XX_ETH_SMI_REG                                         0x20=
10
+#else
 #define MV643XX_ETH_SMI_REG                                         0x20=
04
+#endif
 #define MV643XX_ETH_UNIT_DEFAULT_ADDR_REG                           0x20=
08
 #define MV643XX_ETH_UNIT_DEFAULTID_REG                              0x20=
0c
 #define MV643XX_ETH_UNIT_INTERRUPT_CAUSE_REG                        0x20=
80
@@ -693,6 +697,21 @@
 #define MV643XX_ETH_HIGH_ADDR_REMAP_REG_3                           0x22=
8c
 #define MV643XX_ETH_BASE_ADDR_ENABLE_REG                            0x22=
90
 #define MV643XX_ETH_ACCESS_PROTECTION_REG(port)                    (0x22=
94 + (port<<2))
+#ifdef CONFIG_GT64260
+#define MV643XX_ETH_PORT_CONFIG_REG(port)                          (0x24=
00 + (port<<10))
+#define MV643XX_ETH_PORT_CONFIG_EXTEND_REG(port)                   (0x24=
08 + (port<<10))
+#define MV643XX_ETH_PORT_STATUS_REG(port)                          (0x24=
18 + (port<<10))
+#define GT64260_ETH_HASH_TABLE_POINTER_REG(port)                   (0x24=
28 + (port<<10))
+#define MV643XX_ETH_SDMA_CONFIG_REG(port)                          (0x24=
40 + (port<<10))
+#define MV643XX_ETH_SDMA_COMMAND_REG(port)                         (0x24=
48 + (port<<10))
+#define MV643XX_ETH_INTERRUPT_CAUSE_REG(port)                      (0x24=
50 + (port<<10))
+#define MV643XX_ETH_INTERRUPT_MASK_REG(port)                       (0x24=
58 + (port<<10))
+#define MV643XX_ETH_VLAN_PRIORITY_TAG_TO_PRIORITY(port)            (0x24=
70 + (port<<10))
+#define MV643XX_ETH_RX_FIRST_QUEUE_DESC_PTR_0(port)                (0x24=
80 + (port<<10))
+#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_0(port)              (0x24=
a0 + (port<<10))
+#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_0(port)              (0x24=
e0 + (port<<10))
+#define MV643XX_ETH_MIB_COUNTERS_BASE(port)                        (0x25=
00 + (port<<7))
+#else
 #define MV643XX_ETH_MIB_COUNTERS_BASE(port)                        (0x30=
00 + (port<<7))
 #define MV643XX_ETH_PORT_CONFIG_REG(port)                          (0x24=
00 + (port<<10))
 #define MV643XX_ETH_PORT_CONFIG_EXTEND_REG(port)                   (0x24=
04 + (port<<10))
@@ -775,6 +794,7 @@
 #define MV643XX_ETH_DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE(port)   (0x34=
00 + (port<<10))
 #define MV643XX_ETH_DA_FILTER_OTHER_MULTICAST_TABLE_BASE(port)     (0x35=
00 + (port<<10))
 #define MV643XX_ETH_DA_FILTER_UNICAST_TABLE_BASE(port)             (0x36=
00 + (port<<10))
+#endif
=20
 /*******************************************/
 /*          CUNIT  Registers               */
@@ -1094,6 +1114,45 @@
 };
=20
 /* These macros describe Ethernet Port configuration reg (Px_cR) bits */=

+#define GT64260_ETH_RECEIVE_BC			0
+#define GT64260_ETH_REJECT_BC			(1<<1)
+#define GT64260_ETH_REJECT_BAD_FRAMES		0
+#define GT64260_ETH_RECEIVE_BAD_FRAMES		(1<<2)
+#define GT64260_ETH_DISABLE			0
+#define GT64260_ETH_ENABLE			(1<<7)
+#define GT64260_ETH_CLR_INT_LOOPBACK		0
+#define GT64260_ETH_SET_INT_LOOPBACK		(1<<8)
+#define GT64260_ETH_CLR_EXT_LOOPBACK		0
+#define GT64260_ETH_SET_EXT_LOOPBACK		(1<<9)
+#define GT64260_ETH_DISABLE_FORCE_COLLISION	0
+#define GT64260_ETH_ENABLE_FORCE_COLLISION	(1<<10)
+#define GT64260_ETH_HASH_SIZE_HALFK		0
+#define GT64260_ETH_HASH_SIZE_8K		(1<<12)
+#define GT64260_ETH_HASH_SIZE_SHIFT		12
+#define GT64260_ETH_HASH_MODE_0			0
+#define GT64260_ETH_HASH_MODE_1			(1<<13)
+#define GT64260_ETH_HASH_MODE_SHIFT		13
+#define GT64260_ETH_HASH_DEFAULT_DISCARD	0
+#define GT64260_ETH_HASH_DEFAULT_PASS		(1<<14)
+#define GT64260_ETH_HASH_DEFAULT_SHIFT		14
+#define GT64260_ETH_SET_HALF_DUPLEX_MODE	0
+#define GT64260_ETH_SET_FULL_DUPLEX_MODE	(1<<15)
+#define GT64260_ETH_DISABLE_ACCEL_SLOT_TIME	0
+#define GT64260_ETH_ENABLE_ACCEL_SLOT_TIME	(1<<31)
+
+#define	GT64260_ETH_PORT_CONFIG_DEFAULT_VALUE			\
+		GT64260_ETH_RECEIVE_BC			|	\
+		GT64260_ETH_REJECT_BAD_FRAMES		|	\
+		GT64260_ETH_DISABLE			|	\
+		GT64260_ETH_CLR_INT_LOOPBACK		|	\
+		GT64260_ETH_CLR_EXT_LOOPBACK		|	\
+		GT64260_ETH_DISABLE_FORCE_COLLISION	|	\
+		GT64260_ETH_HASH_SIZE_HALFK		|	\
+		GT64260_ETH_HASH_MODE_0			|	\
+		GT64260_ETH_HASH_DEFAULT_DISCARD	|	\
+		GT64260_ETH_SET_FULL_DUPLEX_MODE	|	\
+		GT64260_ETH_DISABLE_ACCEL_SLOT_TIME
+
 #define MV643XX_ETH_UNICAST_NORMAL_MODE		0
 #define MV643XX_ETH_UNICAST_PROMISCUOUS_MODE	(1<<0)
 #define MV643XX_ETH_DEFAULT_RX_QUEUE_0		0
@@ -1162,6 +1221,59 @@
 		MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_0
=20
 /* These macros describe Ethernet Port configuration extend reg (Px_cXR)=
 bits*/
+#define GT64260_ETH_IGMP_CAPTURE_ENABLE			0
+#define GT64260_ETH_IGMP_CAPTURE_DISABLE		(1<<0)
+#define GT64260_ETH_BPDU_PACKETS_AS_NORMAL		0
+#define GT64260_ETH_BPDU_PACKETS_TO_RX_QUEUE		(1<<1)
+#define GT64260_ETH_PARTITION_DISABLE			0
+#define GT64260_ETH_PARTITION_ENABLE			(1<<2)
+#define GT64260_ETH_PARTITION_DISABLE			0
+#define GT64260_ETH_TX_PRIORITY_1_HIGH_1_LOW		0
+#define GT64260_ETH_TX_PRIORITY_2_HIGH_1_LOW		(0x1<<3)
+#define GT64260_ETH_TX_PRIORITY_4_HIGH_1_LOW		(0x2<<3)
+#define GT64260_ETH_TX_PRIORITY_6_HIGH_1_LOW		(0x3<<3)
+#define GT64260_ETH_TX_PRIORITY_8_HIGH_1_LOW		(0x4<<3)
+#define GT64260_ETH_TX_PRIORITY_10_HIGH_1_LOW		(0x5<<3)
+#define GT64260_ETH_TX_PRIORITY_12_HIGH_1_LOW		(0x6<<3)
+#define GT64260_ETH_TX_PRIORITY_ALL_HIGH_0_LOW		(0x7<<3)
+#define GT64260_ETH_TX_PRIORITY_MASK			(0x7<<3)
+#define GT64260_ETH_RX_PRIORITY_LOWEST			0
+#define GT64260_ETH_RX_PRIORITY_HIGHEST			(0x3<<6)
+#define GT64260_ETH_RX_PRIORITY_OVERRIDE_DISABLE	0
+#define GT64260_ETH_RX_PRIORITY_OVERRIDE_ENABLE		(1<<8)
+#define GT64260_ETH_ENABLE_AUTO_NEG_FOR_DPLX		0
+#define GT64260_ETH_DISABLE_AUTO_NEG_FOR_DPLX		(1<<9)
+#define GT64260_ETH_ENABLE_AUTO_NEG_FOR_FLOW_CTRL	0
+#define GT64260_ETH_DISABLE_AUTO_NEG_FOR_FLOW_CTRL	(1<<10)
+#define GT64260_ETH_FORCE_LINK_PASS			0
+#define GT64260_ETH_DO_NOT_FORCE_LINK_PASS		(1<<11)
+#define GT64260_ETH_DISABLE_FLOW_CTRL			0
+#define GT64260_ETH_ENABLE_FLOW_CTRL			(1<<12)
+/* Bit 13 is reserved. */
+#define GT64260_ETH_MAX_RX_PACKET_1518BYTE		0
+#define GT64260_ETH_MAX_RX_PACKET_1536BYTE		(0x1<<14)
+#define GT64260_ETH_MAX_RX_PACKET_2048BYTE		(0x2<<14)
+#define GT64260_ETH_MAX_RX_PACKET_64KBYTE		(0x3<<14)
+#define GT64260_ETH_MAX_RX_PACKET_MASK			(0x7<<14)
+#define GT64260_ETH_CLR_MIB_COUNTERS			0
+/* Bit 17 is undocumented. */
+#define GT64260_ETH_SET_SPEED_TO_10			0
+#define GT64260_ETH_SET_SPEED_TO_100			(1<<18)
+#define GT64260_ETH_ENABLE_AUTONEG_FOR_SPEED		0
+#define GT64260_ETH_DISABLE_AUTONEG_FOR_SPEED		(1<<19)
+#define GT64260_ETH_ENABLE_MII				0
+#define GT64260_ETH_ENABLE_RMII				(1<<20)
+#define GT64260_ETH_DISABLE_DSCP			0
+#define GT64260_ETH_ENABLE_DSCP				(1<<21)
+/* Bits 22 - 31 are reserved. */
+
+#define	GT64260_ETH_PORT_CONFIG_EXTEND_DEFAULT_VALUE		\
+		GT64260_ETH_RX_PRIORITY_OVERRIDE_ENABLE	|	\
+		GT64260_ETH_DISABLE_AUTO_NEG_FOR_FLOW_CTRL |	\
+		GT64260_ETH_DO_NOT_FORCE_LINK_PASS	|	\
+		GT64260_ETH_MAX_RX_PACKET_1536BYTE	|	\
+		GT64260_ETH_ENABLE_RMII
+
 #define MV643XX_ETH_CLASSIFY_EN				(1<<0)
 #define MV643XX_ETH_SPAN_BPDU_PACKETS_AS_NORMAL		0
 #define MV643XX_ETH_SPAN_BPDU_PACKETS_TO_RX_QUEUE_7	(1<<1)
@@ -1173,6 +1285,23 @@
 		MV643XX_ETH_PARTITION_DISABLE
=20
 /* These macros describe Ethernet Port Sdma configuration reg (SDCR) bit=
s */
+#define GT64260_ETH_RETRANSMIT_COUNT_MASK		(0xf<<2)
+#define GT64260_ETH_BLM_RX_NO_SWAP			0
+#define GT64260_ETH_BLM_RX_BYTE_SWAP			(1<<6)
+#define GT64260_ETH_BLM_TX_NO_SWAP			0
+#define GT64260_ETH_BLM_TX_BYTE_SWAP			(1<<7)
+#define GT64260_ETH_PCI_OVERRIDE			(1<<8)
+#define GT64260_ETH_RIFB				(1<<9)
+#define GT64260_ETH_BURST_SIZE_1_64BIT			(0x0<<12)
+#define GT64260_ETH_BURST_SIZE_2_64BIT			(0x1<<12)
+#define GT64260_ETH_BURST_SIZE_4_64BIT			(0x2<<12)
+#define GT64260_ETH_BURST_SIZE_8_64BIT			(0x3<<12)
+
+#define	GT64260_ETH_PORT_SDMA_CONFIG_DEFAULT_VALUE		\
+		GT64260_ETH_RETRANSMIT_COUNT_MASK	|	\
+		GT64260_ETH_RIFB			|	\
+		GT64260_ETH_BURST_SIZE_4_64BIT
+
 #define MV643XX_ETH_RIFB			(1<<0)
 #define MV643XX_ETH_RX_BURST_SIZE_1_64BIT		0
 #define MV643XX_ETH_RX_BURST_SIZE_2_64BIT		(1<<1)
@@ -1198,6 +1327,13 @@
 		MV643XX_ETH_IPG_INT_RX(0)		|	\
 		MV643XX_ETH_TX_BURST_SIZE_4_64BIT
=20
+/* These macros describe Ethernet Port Sdma command reg (SDCMR) bits */
+#define GT64260_ETH_ENABLE_RX_DMA			(1<<7)
+#define GT64260_ETH_ABORT_RX_DMA			(1<<15)
+#define GT64260_ETH_START_TX_HIGH			(1<<23)
+#define GT64260_ETH_START_TX_LOW			(1<<24)
+#define GT64260_ETH_ABORT_TX_DMA			(1<<31)
+
 /* These macros describe Ethernet Port serial control reg (PSCR) bits */=

 #define MV643XX_ETH_SERIAL_PORT_DISABLE			0
 #define MV643XX_ETH_SERIAL_PORT_ENABLE			(1<<0)
@@ -1279,7 +1417,10 @@
 #define MV643XX_ETH_PORT_STATUS_TX_FIFO_EMPTY		(1<<10)
 /* PSR bits 11-31 are reserved */
=20
+/* Default TX ring size is 800 descriptors */
 #define	MV643XX_ETH_PORT_DEFAULT_TRANSMIT_QUEUE_SIZE	800
+
+/* Default RX ring size is 400 descriptors */
 #define	MV643XX_ETH_PORT_DEFAULT_RECEIVE_QUEUE_SIZE	400
=20
 #define MV643XX_ETH_DESC_SIZE				64

--------------040201090408000508060705--

--------------enigFF9D409EAAF9D8A60112DF74
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFGnuz/gyK5H2Ic36cRAryxAJsF8lj2tQV7uxPJlcbQJNcec1L/6ACfSWd9
AO1KyhNiZhG42ZB7PVBW5N4=
=mmqE
-----END PGP SIGNATURE-----

--------------enigFF9D409EAAF9D8A60112DF74--
