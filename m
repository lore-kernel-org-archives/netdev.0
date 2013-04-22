From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with Linus' tree
Date: Mon, 22 Apr 2013 12:48:50 +1000
Message-ID: <20130422124850.1ced8160a7be1375b4824ebc@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__22_Apr_2013_12_48_50_+1000_5UWpFMXqcfj6_3hr"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__22_Apr_2013_12_48_50_+1000_5UWpFMXqcfj6_3hr
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/ethernet/intel/igb/igb_main.c between commit f9d40f6a9921
("igb: Revert support for build_skb in igb") from Linus' tree and commit
b980ac18c95f ("igb: Fix code comments and whitespace") from the net-next
tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/ethernet/intel/igb/igb_main.c
index 64f7529,9bf08b9..0000000
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@@ -3350,11 -3387,25 +3387,11 @@@ void igb_configure_rx_ring(struct igb_a
  	wr32(E1000_RXDCTL(reg_idx), rxdctl);
  }
 =20
 -static void igb_set_rx_buffer_len(struct igb_adapter *adapter,
 -				  struct igb_ring *rx_ring)
 -{
 -#define IGB_MAX_BUILD_SKB_SIZE \
 -	(SKB_WITH_OVERHEAD(IGB_RX_BUFSZ) - \
 -	 (NET_SKB_PAD + NET_IP_ALIGN + IGB_TS_HDR_LEN))
 -
 -	/* set build_skb flag */
 -	if (adapter->max_frame_size <=3D IGB_MAX_BUILD_SKB_SIZE)
 -		set_ring_build_skb_enabled(rx_ring);
 -	else
 -		clear_ring_build_skb_enabled(rx_ring);
 -}
 -
  /**
-  * igb_configure_rx - Configure receive Unit after Reset
-  * @adapter: board private structure
+  *  igb_configure_rx - Configure receive Unit after Reset
+  *  @adapter: board private structure
   *
-  * Configure the Rx unit of the MAC after a reset.
+  *  Configure the Rx unit of the MAC after a reset.
   **/
  static void igb_configure_rx(struct igb_adapter *adapter)
  {
@@@ -3365,12 -3416,16 +3402,13 @@@
 =20
  	/* set the correct pool for the PF default MAC address in entry 0 */
  	igb_rar_set_qsel(adapter, adapter->hw.mac.addr, 0,
- 	                 adapter->vfs_allocated_count);
+ 			 adapter->vfs_allocated_count);
 =20
  	/* Setup the HW Rx Head and Tail Descriptor Pointers and
- 	 * the Base and Length of the Rx Descriptor Ring */
+ 	 * the Base and Length of the Rx Descriptor Ring
+ 	 */
 -	for (i =3D 0; i < adapter->num_rx_queues; i++) {
 -		struct igb_ring *rx_ring =3D adapter->rx_ring[i];
 -		igb_set_rx_buffer_len(adapter, rx_ring);
 -		igb_configure_rx_ring(adapter, rx_ring);
 -	}
 +	for (i =3D 0; i < adapter->num_rx_queues; i++)
 +		igb_configure_rx_ring(adapter, adapter->rx_ring[i]);
  }
 =20
  /**
@@@ -6688,9 -6808,17 +6716,9 @@@ static bool igb_alloc_mapped_page(struc
  	return true;
  }
 =20
 -static inline unsigned int igb_rx_offset(struct igb_ring *rx_ring)
 -{
 -	if (ring_uses_build_skb(rx_ring))
 -		return NET_SKB_PAD + NET_IP_ALIGN;
 -	else
 -		return 0;
 -}
 -
  /**
-  * igb_alloc_rx_buffers - Replace used receive buffers; packet split
-  * @adapter: address of board private structure
+  *  igb_alloc_rx_buffers - Replace used receive buffers; packet split
+  *  @adapter: address of board private structure
   **/
  void igb_alloc_rx_buffers(struct igb_ring *rx_ring, u16 cleaned_count)
  {
@@@ -6710,11 -6838,12 +6738,10 @@@
  		if (!igb_alloc_mapped_page(rx_ring, bi))
  			break;
 =20
- 		/*
- 		 * Refresh the desc even if buffer_addrs didn't change
+ 		/* Refresh the desc even if buffer_addrs didn't change
  		 * because each write-back erases this info.
  		 */
 -		rx_desc->read.pkt_addr =3D cpu_to_le64(bi->dma +
 -						     bi->page_offset +
 -						     igb_rx_offset(rx_ring));
 +		rx_desc->read.pkt_addr =3D cpu_to_le64(bi->dma + bi->page_offset);
 =20
  		rx_desc++;
  		bi++;

--Signature=_Mon__22_Apr_2013_12_48_50_+1000_5UWpFMXqcfj6_3hr
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRdKUSAAoJEECxmPOUX5FE/dcQAJE3Y2a9SD1UKjVBeevjuq9o
RtkPmHiBvSo3Mcewgf5wA5jcZ35QrbYHZtjUpV3LioJdZ5LihrhW5uw+Mnx2ntEv
mJTrO+pskKAn35w/5pwHTUfLP3I30C/BPm3tTh7tAa7IqlbXnJet0yx0CuF5y4Gj
PtYkFY0vpMzu97GhAKRGouDoZJ9tRBvC7U3pHUVBCovEOHUf/rGsJzYGpM1yYMgn
1xl72c6UBjpxxUgMnmTwoWKHWwsuA7szaEt0SXTEd5LnJzMEfEDhJo8HLedoQrdF
XOQUM6AS7bHDjbcg66pOwuPtSiyE1Bah5oTisVyu9POuoF9gMpX9nl0G1MBHmy/G
PmXly7+o1QGMtKaN/znWvGbSb66gLlBSz9A/6RdgpKjkx3BtDS0MbLKUzEgL3T/S
D/7oCE6TJrzUZjwc5h7ZpsZoova1LBMnx5ZqMsf9EqjuwuuxP3FqXOJXfD17JJ93
E5JdN46pBchXJBgu4fZNqwUGfeHy+uCWV2hdEEuaSAHRQDo+uxh0vo5wqoKpXYEC
+GM2pUMfb9eRt8TC07TW3oUJNeXxICH2CPMIKRh1irjLehpmDDf9fYC+lblvaDdT
KM2LTFAwrz6uyPtJeCfSYeH3Z13zaSDZK00LUu7wC/fMYR5hnC7MXu7n/2v0XpKz
qducuZhQVQRy6JEbAYJL
=pjUn
-----END PGP SIGNATURE-----

--Signature=_Mon__22_Apr_2013_12_48_50_+1000_5UWpFMXqcfj6_3hr--
