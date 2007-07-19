From: "Steven J. Hill" <sjhill@realitydiluted.com>
Subject: [PATCH] Merge GT/MV642xx Support into MV643xx Driver [3/8]
Date: Wed, 18 Jul 2007 23:51:55 -0500
Message-ID: <469EEDEB.9020804@realitydiluted.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigA751856B3EA42DC7038EFB5B"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from real.realitydiluted.com ([66.43.201.61]:49737 "EHLO
	real.realitydiluted.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752243AbXGSFYh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 01:24:37 -0400
Received: from atlas.inter.net ([10.0.0.3])
	by real.realitydiluted.com with esmtp (Exim 4.67)
	(envelope-from <sjhill@realitydiluted.com>)
	id 1IBO1h-00066U-64
	for netdev@vger.kernel.org; Wed, 18 Jul 2007 23:54:12 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigA751856B3EA42DC7038EFB5B
Content-Type: multipart/mixed;
 boundary="------------090801070004090201000006"

This is a multi-part message in MIME format.
--------------090801070004090201000006
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Add 642xx support to 'drivers/net/mv643xx_eth.h'

Signed-off-by: Steven J. Hill <sjhill1@rockwellcollins.com>
---

--------------090801070004090201000006
Content-Type: text/x-patch;
 name="03-mv643xx-64260-driver-header.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline;
 filename="03-mv643xx-64260-driver-header.patch"

--- linux-2.6.22.1/drivers/net/mv643xx_eth.h	2007-07-11 08:53:06.00000000=
0 -0500
+++ linux-2.6.22.1-rci/drivers/net/mv643xx_eth.h	2007-07-11 09:28:16.0000=
00000 -0500
@@ -14,8 +14,13 @@
 /* Checksum offload for Tx works for most packets, but
  * fails if previous packet sent did not use hw csum
  */
+#ifdef CONFIG_GT64260
+#undef	MV643XX_CHECKSUM_OFFLOAD_TX
+#undef	MV643XX_NAPI
+#else
 #define	MV643XX_CHECKSUM_OFFLOAD_TX
 #define	MV643XX_NAPI
+#endif
 #define	MV643XX_TX_FAST_REFILL
 #undef	MV643XX_COAL
=20
@@ -54,17 +59,31 @@
 #define ETH_RX_QUEUES_ENABLED	(1 << 0)	/* use only Q0 for receive */
 #define ETH_TX_QUEUES_ENABLED	(1 << 0)	/* use only Q0 for transmit */
=20
+#ifdef CONFIG_GT64260
+#define ETH_INT_CAUSE_RX_DONE	(ETH_RX_QUEUES_ENABLED << 16)
+#define ETH_INT_CAUSE_RX_ERROR	(ETH_RX_QUEUES_ENABLED << 20)
+#define ETH_INT_CAUSE_RX	(ETH_INT_CAUSE_RX_DONE | ETH_INT_CAUSE_RX_ERROR=
)
+#define ETH_INT_UNMASK_ALL	0x30ff010d
+#else
 #define ETH_INT_CAUSE_RX_DONE	(ETH_RX_QUEUES_ENABLED << 2)
 #define ETH_INT_CAUSE_RX_ERROR	(ETH_RX_QUEUES_ENABLED << 9)
 #define ETH_INT_CAUSE_RX	(ETH_INT_CAUSE_RX_DONE | ETH_INT_CAUSE_RX_ERROR=
)
 #define ETH_INT_CAUSE_EXT	0x00000002
 #define ETH_INT_UNMASK_ALL	(ETH_INT_CAUSE_RX | ETH_INT_CAUSE_EXT)
+#endif
=20
+#ifdef CONFIG_GT64260
+#define ETH_INT_CAUSE_TX_DONE	(ETH_TX_QUEUES_ENABLED << 2)
+#define ETH_INT_CAUSE_TX_ERROR	(ETH_TX_QUEUES_ENABLED << 10)
+#define ETH_INT_CAUSE_TX	(ETH_INT_CAUSE_TX_DONE | ETH_INT_CAUSE_TX_ERROR=
)
+#define ETH_INT_CAUSE_PHY	0x10000000
+#else
 #define ETH_INT_CAUSE_TX_DONE	(ETH_TX_QUEUES_ENABLED << 0)
 #define ETH_INT_CAUSE_TX_ERROR	(ETH_TX_QUEUES_ENABLED << 8)
 #define ETH_INT_CAUSE_TX	(ETH_INT_CAUSE_TX_DONE | ETH_INT_CAUSE_TX_ERROR=
)
 #define ETH_INT_CAUSE_PHY	0x00010000
 #define ETH_INT_UNMASK_ALL_EXT	(ETH_INT_CAUSE_TX | ETH_INT_CAUSE_PHY)
+#endif
=20
 #define ETH_INT_MASK_ALL	0x00000000
 #define ETH_INT_MASK_ALL_EXT	0x00000000
@@ -73,11 +92,42 @@
 #define PHY_WAIT_MICRO_SECONDS	10
=20
 /* Buffer offset from buffer pointer */
+#ifdef CONFIG_GT64260
+#define RX_BUF_OFFSET				0x4
+#else
 #define RX_BUF_OFFSET				0x2
+#endif
=20
 /* Gigabit Ethernet Unit Global Registers */
=20
 /* MIB Counters register definitions */
+#ifdef CONFIG_GT64260
+#define ETH_MIB_OCTETS_RECEIVED			0x0
+#define ETH_MIB_OCTETS_SENT			0x4
+#define ETH_MIB_FRAMES_RECEIVED			0x8
+#define ETH_MIB_FRAMES_SENT			0xc
+#define ETH_MIB_TOTAL_OCTETS_RECEIVED		0x10
+#define ETH_MIB_TOTAL_FRAMES_RECEIVED		0x14
+#define ETH_MIB_BROADCAST_FRAMES_RECEIVED	0x18
+#define ETH_MIB_MULTICAST_FRAMES_RECEIVED	0x1c
+#define ETH_MIB_BAD_CRC_EVENT			0x20
+#define ETH_MIB_OVERSIZE_RECEIVED		0x24
+#define ETH_MIB_FRAGMENTS_RECEIVED		0x28
+#define ETH_MIB_JABBER_RECEIVED			0x2c
+#define ETH_MIB_COLLISION			0x30
+#define ETH_MIB_LATE_COLLISION			0x34
+#define ETH_MIB_FRAMES_64_OCTETS		0x38
+#define ETH_MIB_FRAMES_65_TO_127_OCTETS		0x3c
+#define ETH_MIB_FRAMES_128_TO_255_OCTETS	0x40
+#define ETH_MIB_FRAMES_256_TO_511_OCTETS	0x44
+#define ETH_MIB_FRAMES_512_TO_1023_OCTETS	0x48
+#define ETH_MIB_FRAMES_1024_TO_MAX_OCTETS	0x4c
+#define ETH_MIB_MAC_RECEIVE_ERROR		0x50
+#define ETH_MIB_DROPPED_FRAMES			0x54
+#define ETH_MIB_MULTICAST_FRAMES_SENT		0x58
+#define ETH_MIB_BROADCAST_FRAMES_SENT		0x5c
+#define ETH_MIB_UNDERSIZE_RECEIVED		0x60
+#else
 #define ETH_MIB_GOOD_OCTETS_RECEIVED_LOW	0x0
 #define ETH_MIB_GOOD_OCTETS_RECEIVED_HIGH	0x4
 #define ETH_MIB_BAD_OCTETS_RECEIVED		0x8
@@ -110,6 +160,7 @@
 #define ETH_MIB_BAD_CRC_EVENT			0x74
 #define ETH_MIB_COLLISION			0x78
 #define ETH_MIB_LATE_COLLISION			0x7c
+#endif
=20
 /* Port serial status reg (PSR) */
 #define ETH_INTERFACE_PCM			0x00000001
@@ -134,18 +185,35 @@
 /* SDMA command status fields macros */
=20
 /* Tx & Rx descriptors status */
+#ifdef CONFIG_GT64260
+#define ETH_ERROR_SUMMARY			0x00008000
+#else
 #define ETH_ERROR_SUMMARY			0x00000001
+#endif
=20
 /* Tx & Rx descriptors command */
 #define ETH_BUFFER_OWNED_BY_DMA			0x80000000
=20
 /* Tx descriptors status */
+#ifdef CONFIG_GT64260
+#define ETH_LC_ERROR				0x00000020
+#define ETH_UR_ERROR				0x00000040
+#define ETH_RL_ERROR				0x00000100
+#else
 #define ETH_LC_ERROR				0
 #define ETH_UR_ERROR				0x00000002
 #define ETH_RL_ERROR				0x00000004
 #define ETH_LLC_SNAP_FORMAT			0x00000200
+#endif
=20
 /* Rx descriptors status */
+#ifdef CONFIG_GT64260
+#define ETH_OVERRUN_ERROR			0x00000040
+#define ETH_MAX_FRAME_LENGTH_ERROR		0x00000080
+#define ETH_RX_LAST_DESC			0x00010000
+#define ETH_RX_FIRST_DESC			0x00020000
+#define ETH_RX_ENABLE_INTERRUPT			0x00800000
+#else
 #define ETH_OVERRUN_ERROR			0x00000002
 #define ETH_MAX_FRAME_LENGTH_ERROR		0x00000004
 #define ETH_RESOURCE_ERROR			0x00000006
@@ -161,11 +229,19 @@
 #define ETH_UNKNOWN_DESTINATION_ADDR		0x10000000
 #define ETH_RX_ENABLE_INTERRUPT			0x20000000
 #define ETH_LAYER_4_CHECKSUM_OK			0x40000000
+#endif
=20
 /* Rx descriptors byte count */
 #define ETH_FRAME_FRAGMENTED			0x00000004
=20
 /* Tx descriptors command */
+#ifdef CONFIG_GT64260
+#define ETH_ZERO_PADDING			0x00040000
+#define ETH_TX_LAST_DESC			0x00010000
+#define ETH_TX_FIRST_DESC			0x00020000
+#define ETH_GEN_CRC				0x00400000
+#define ETH_TX_ENABLE_INTERRUPT			0x00800000
+#else
 #define ETH_LAYER_4_CHECKSUM_FIRST_DESC		0x00000400
 #define ETH_FRAME_SET_TO_VLAN			0x00008000
 #define ETH_UDP_FRAME				0x00010000
@@ -177,6 +253,7 @@
 #define ETH_GEN_CRC				0x00400000
 #define ETH_TX_ENABLE_INTERRUPT			0x00800000
 #define ETH_AUTO_MODE				0x40000000
+#endif
=20
 #define ETH_TX_IHL_SHIFT			11
=20
@@ -204,11 +281,27 @@
  */
 #if defined(__BIG_ENDIAN)
 struct eth_rx_desc {
+# ifdef CONFIG_GT64260
+	u16 buf_size;		/* Buffer size				*/
+	u16 byte_cnt;		/* Descriptor buffer byte count		*/
+	u32 cmd_sts;		/* Descriptor command status		*/
+	u32 next_desc_ptr;	/* Next descriptor pointer		*/
+	u32 buf_ptr;		/* Descriptor buffer pointer		*/
+
+	/*
+	 * Force sizeof(gt64260enetDMAdescriptor) =3D=3D sizeof(cacheline)
+	 * Not yet sure exactly why this is necessary but the GT64260-B
+	 * part apparently has (yet another) bug that shows itself without
+	 * this padding.  The symptom is that all Enet comms simply stop.
+	 */
+	u32 cachelineSizePadding[4];
+# else
 	u16 byte_cnt;		/* Descriptor buffer byte count		*/
 	u16 buf_size;		/* Buffer size				*/
 	u32 cmd_sts;		/* Descriptor command status		*/
 	u32 next_desc_ptr;	/* Next descriptor pointer		*/
 	u32 buf_ptr;		/* Descriptor buffer pointer		*/
+# endif
 };
=20
 struct eth_tx_desc {
@@ -217,15 +310,32 @@
 	u32 cmd_sts;		/* Command/status field			*/
 	u32 next_desc_ptr;	/* Pointer to next descriptor		*/
 	u32 buf_ptr;		/* pointer to buffer for this descriptor*/
+# ifdef CONFIG_GT64260
+	/*
+	 * Force sizeof(gt64260enetDMAdescriptor) =3D=3D sizeof(cacheline)
+	 * Not yet sure exactly why this is necessary but the GT64260-B
+	 * part apparently has (yet another) bug that shows itself without
+	 * this padding.  The symptom is that all Enet comms simply stop.
+	 */
+	u32 cachelineSizePadding[4];
+# endif
 };
=20
 #elif defined(__LITTLE_ENDIAN)
 struct eth_rx_desc {
+# ifdef CONFIG_GT64260
+	u32 cmd_sts;		/* Descriptor command status		*/
+	u16 byte_cnt;		/* Descriptor buffer byte count		*/
+	u16 buf_size;		/* Buffer size				*/
+	u32 buf_ptr;		/* Descriptor buffer pointer		*/
+	u32 next_desc_ptr;	/* Next descriptor pointer		*/
+# else
 	u32 cmd_sts;		/* Descriptor command status		*/
 	u16 buf_size;		/* Buffer size				*/
 	u16 byte_cnt;		/* Descriptor buffer byte count		*/
 	u32 buf_ptr;		/* Descriptor buffer pointer		*/
 	u32 next_desc_ptr;	/* Next descriptor pointer		*/
+# endif
 };
=20
 struct eth_tx_desc {
@@ -249,8 +359,53 @@
 	struct sk_buff *return_info;	/* User resource return information */
 };
=20
+#ifdef CONFIG_GT64260
+struct eth_hash_table_entry {
+	u32 hi;
+	u32 lo;
+};
+
+#define MAC_ENTRY_SIZE	sizeof(struct eth_hash_table_entry)
+
+/* Cache helper macros */
+#define flush_dcache_addr_size(addr, length)			\
+	flush_dcache_range((u32) addr, (((u32) addr) + length))
+
+#define invalidate_dcache_addr_size(addr, length)			\
+	invalidate_dcache_range((u32) addr, (((u32) addr) + length))
+#endif
+
 /* Ethernet port specific information */
=20
+#ifdef CONFIG_GT64260
+struct gt64260_mib_counters {
+	u32 good_octets_received;
+	u32 good_octets_sent;
+	u32 good_frames_received;
+	u32 good_frames_sent;
+	u32 total_octets_received;
+	u32 total_frames_received;
+	u32 broadcast_frames_received;
+	u32 multicast_frames_received;
+	u32 bad_crc_event;
+	u32 oversize_received;
+	u32 fragments_received;
+	u32 jabber_received;
+	u32 collision;
+	u32 late_collision;
+	u32 frames_64_octets;
+	u32 frames_65_to_127_octets;
+	u32 frames_128_to_255_octets;
+	u32 frames_256_to_511_octets;
+	u32 frames_512_to_1023_octets;
+	u32 frames_1024_to_max_octets;
+	u32 mac_receive_error;
+	u32 dropped_frames;
+	u32 multicast_frames_sent;
+	u32 broadcast_frames_sent;
+	u32 undersize_received;
+};
+#else
 struct mv643xx_mib_counters {
 	u64 good_octets_received;
 	u32 bad_octets_received;
@@ -283,6 +438,7 @@
 	u32 collision;
 	u32 late_collision;
 };
+#endif
=20
 struct mv643xx_private {
 	int port_num;			/* User Ethernet port number	*/
@@ -294,7 +450,7 @@
=20
 	int rx_resource_err;		/* Rx ring resource error flag */
=20
-	/* Tx/Rx rings managment indexes fields. For driver use */
+	/* Tx/Rx rings management indexes fields. For driver use */
=20
 	/* Next available and first returning Rx resource */
 	int rx_curr_desc_q, rx_used_desc_q;
@@ -319,7 +475,14 @@
 	struct work_struct tx_timeout_task;
=20
 	struct net_device_stats stats;
+#ifdef CONFIG_GT64260
+	struct gt64260_mib_counters mib_counters;
+	struct eth_hash_table_entry *eth_hash_table;
+	dma_addr_t eth_hash_table_dma;
+	int eth_hash_table_size;
+#else
 	struct mv643xx_mib_counters mib_counters;
+#endif
 	spinlock_t lock;
 	/* Size of Tx Ring per queue */
 	int tx_ring_size;

--------------090801070004090201000006--

--------------enigA751856B3EA42DC7038EFB5B
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFGnu3rgyK5H2Ic36cRAkPgAKCS8/41i+TQfuU2KtIxABAgUv3xowCfVWmt
ls0u8uKiO2ncJ4oXEVJmGAI=
=0gO/
-----END PGP SIGNATURE-----

--------------enigA751856B3EA42DC7038EFB5B--
