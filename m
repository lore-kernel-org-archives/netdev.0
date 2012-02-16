From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Thu, 16 Feb 2012 12:38:03 +1100
Message-ID: <20120216123803.8efe3d23eee5c3a80aceef61@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__16_Feb_2012_12_38_03_+1100_dQp+EHQ2ECH2ggCo"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mintz Yuval <yuvalmin@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__16_Feb_2012_12_38_03_+1100_dQp+EHQ2ECH2ggCo
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c between commit
66d885cba670 ("bnx2x: fix bnx2x_storm_stats_update() on big endian") from
the net tree and commit 1355b704b9ba ("bnx2x: consistent statistics after
internal driver reload") from the net-next tree.

I fixed it up (see below) but suspect that there may be more needed.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
index 1adef26,abd310d..0000000
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
@@@ -1006,97 -980,43 +980,43 @@@ static int bnx2x_storm_stats_update(str
  				    total_transmitted_dropped_packets_error);
 =20
  		/* TPA aggregations completed */
- 		UPDATE_EXTEND_USTAT(coalesced_events, total_tpa_aggregations);
+ 		UPDATE_EXTEND_E_USTAT(coalesced_events, total_tpa_aggregations);
  		/* Number of network frames aggregated by TPA */
- 		UPDATE_EXTEND_USTAT(coalesced_pkts,
- 				    total_tpa_aggregated_frames);
+ 		UPDATE_EXTEND_E_USTAT(coalesced_pkts,
+ 				      total_tpa_aggregated_frames);
  		/* Total number of bytes in completed TPA aggregations */
- 		qstats->total_tpa_bytes_lo =3D
- 			le32_to_cpu(uclient->coalesced_bytes.lo);
- 		qstats->total_tpa_bytes_hi =3D
- 			le32_to_cpu(uclient->coalesced_bytes.hi);
-=20
- 		/* TPA stats per-function */
- 		ADD_64(estats->total_tpa_aggregations_hi,
- 		       qstats->total_tpa_aggregations_hi,
- 		       estats->total_tpa_aggregations_lo,
- 		       qstats->total_tpa_aggregations_lo);
- 		ADD_64(estats->total_tpa_aggregated_frames_hi,
- 		       qstats->total_tpa_aggregated_frames_hi,
- 		       estats->total_tpa_aggregated_frames_lo,
- 		       qstats->total_tpa_aggregated_frames_lo);
- 		ADD_64(estats->total_tpa_bytes_hi,
- 		       qstats->total_tpa_bytes_hi,
- 		       estats->total_tpa_bytes_lo,
- 		       qstats->total_tpa_bytes_lo);
-=20
- 		ADD_64(fstats->total_bytes_received_hi,
- 		       qstats->total_bytes_received_hi,
- 		       fstats->total_bytes_received_lo,
- 		       qstats->total_bytes_received_lo);
- 		ADD_64(fstats->total_bytes_transmitted_hi,
- 		       qstats->total_bytes_transmitted_hi,
- 		       fstats->total_bytes_transmitted_lo,
- 		       qstats->total_bytes_transmitted_lo);
- 		ADD_64(fstats->total_unicast_packets_received_hi,
- 		       qstats->total_unicast_packets_received_hi,
- 		       fstats->total_unicast_packets_received_lo,
- 		       qstats->total_unicast_packets_received_lo);
- 		ADD_64(fstats->total_multicast_packets_received_hi,
- 		       qstats->total_multicast_packets_received_hi,
- 		       fstats->total_multicast_packets_received_lo,
- 		       qstats->total_multicast_packets_received_lo);
- 		ADD_64(fstats->total_broadcast_packets_received_hi,
- 		       qstats->total_broadcast_packets_received_hi,
- 		       fstats->total_broadcast_packets_received_lo,
- 		       qstats->total_broadcast_packets_received_lo);
- 		ADD_64(fstats->total_unicast_packets_transmitted_hi,
- 		       qstats->total_unicast_packets_transmitted_hi,
- 		       fstats->total_unicast_packets_transmitted_lo,
- 		       qstats->total_unicast_packets_transmitted_lo);
- 		ADD_64(fstats->total_multicast_packets_transmitted_hi,
- 		       qstats->total_multicast_packets_transmitted_hi,
- 		       fstats->total_multicast_packets_transmitted_lo,
- 		       qstats->total_multicast_packets_transmitted_lo);
- 		ADD_64(fstats->total_broadcast_packets_transmitted_hi,
- 		       qstats->total_broadcast_packets_transmitted_hi,
- 		       fstats->total_broadcast_packets_transmitted_lo,
- 		       qstats->total_broadcast_packets_transmitted_lo);
- 		ADD_64(fstats->valid_bytes_received_hi,
- 		       qstats->valid_bytes_received_hi,
- 		       fstats->valid_bytes_received_lo,
- 		       qstats->valid_bytes_received_lo);
-=20
- 		ADD_64(estats->etherstatsoverrsizepkts_hi,
- 		       qstats->etherstatsoverrsizepkts_hi,
- 		       estats->etherstatsoverrsizepkts_lo,
- 		       qstats->etherstatsoverrsizepkts_lo);
- 		ADD_64(estats->no_buff_discard_hi, qstats->no_buff_discard_hi,
- 		       estats->no_buff_discard_lo, qstats->no_buff_discard_lo);
+ 		UPDATE_QSTAT(uclient->coalesced_bytes, total_tpa_bytes);
+=20
+ 		UPDATE_ESTAT_QSTAT_64(total_tpa_bytes);
+=20
+ 		UPDATE_FSTAT_QSTAT(total_bytes_received);
+ 		UPDATE_FSTAT_QSTAT(total_bytes_transmitted);
+ 		UPDATE_FSTAT_QSTAT(total_unicast_packets_received);
+ 		UPDATE_FSTAT_QSTAT(total_multicast_packets_received);
+ 		UPDATE_FSTAT_QSTAT(total_broadcast_packets_received);
+ 		UPDATE_FSTAT_QSTAT(total_unicast_packets_transmitted);
+ 		UPDATE_FSTAT_QSTAT(total_multicast_packets_transmitted);
+ 		UPDATE_FSTAT_QSTAT(total_broadcast_packets_transmitted);
+ 		UPDATE_FSTAT_QSTAT(valid_bytes_received);
  	}
 =20
- 	ADD_64(fstats->total_bytes_received_hi,
+ 	ADD_64(estats->total_bytes_received_hi,
  	       estats->rx_stat_ifhcinbadoctets_hi,
- 	       fstats->total_bytes_received_lo,
+ 	       estats->total_bytes_received_lo,
  	       estats->rx_stat_ifhcinbadoctets_lo);
 =20
- 	ADD_64(fstats->total_bytes_received_hi,
+ 	ADD_64(estats->total_bytes_received_hi,
 -	       tfunc->rcv_error_bytes.hi,
 +	       le32_to_cpu(tfunc->rcv_error_bytes.hi),
- 	       fstats->total_bytes_received_lo,
+ 	       estats->total_bytes_received_lo,
 -	       tfunc->rcv_error_bytes.lo);
 +	       le32_to_cpu(tfunc->rcv_error_bytes.lo));
 =20
- 	memcpy(estats, &(fstats->total_bytes_received_hi),
- 	       sizeof(struct host_func_stats) - 2*sizeof(u32));
-=20
  	ADD_64(estats->error_bytes_received_hi,
 -	       tfunc->rcv_error_bytes.hi,
 +	       le32_to_cpu(tfunc->rcv_error_bytes.hi),
  	       estats->error_bytes_received_lo,
 -	       tfunc->rcv_error_bytes.lo);
 +	       le32_to_cpu(tfunc->rcv_error_bytes.lo));
 =20
- 	ADD_64(estats->etherstatsoverrsizepkts_hi,
- 	       estats->rx_stat_dot3statsframestoolong_hi,
- 	       estats->etherstatsoverrsizepkts_lo,
- 	       estats->rx_stat_dot3statsframestoolong_lo);
+ 	UPDATE_ESTAT(etherstatsoverrsizepkts, rx_stat_dot3statsframestoolong);
+=20
  	ADD_64(estats->error_bytes_received_hi,
  	       estats->rx_stat_ifhcinbadoctets_hi,
  	       estats->error_bytes_received_lo,

--Signature=_Thu__16_Feb_2012_12_38_03_+1100_dQp+EHQ2ECH2ggCo
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJPPF37AAoJEECxmPOUX5FEBGAP/jiWnyFM4mKFKvet9mzn9VLC
9s0n+WsvbHEv9t2FkbzZyuIAF5vVqBthtjv+97jeJCh4RVoQAUeSR61zNJ7N3M5t
BMYsJrAKP4f4Kjn8WqeV3tHM5qQwct8gg8TgDc5Ic41DA2KZyCkKM+xMLtdN0sKH
wffC2vAih+WJhv1UYYFU6l9jGxzMx7ysJE/R3PgKXEWTTucJaOhzaxqzeYItADyp
9d54uyCKAZHuDw4uFn34HPnK/vdd9tsqbJWxiDF0H91WEcmRsqTLpfgqbzozjSo9
Hy0UsTyEdlvlcPxbhG5wvoKDfP+b+9dMM+/PO9VFK3paq4JkEi6NSq9eHRcp0iZY
prN+YuJAx8L1NBdjFhKP/R1SE6Sln6+TNEu/B3m0GZ0DNzNLD2U/kteOffd3Xx3h
j05ZnhqKyUkMWzCsRuV+rLf1FdFCBwNfD632Z/bfNCTw91bEN1eyqKhD82IZYzyy
qZckkriwcw77aJ54Pvb5paS12ubkvATTA61o4rqt8lxlrhPxvnTfP90AbOjNHhwh
lMztVFdyJG4cC/4Lh/eaa/PdlwHlCZ034gyGTlQWE8Tf1TBWF/SQd5ZaIM9hnkk0
0XSG+TtS68pxLJcPzxDDGfbsqp1eiQmsrmx2dLkj/xdigMUcQFLD/EQMJ0a5x8j8
77RgvCMmsXRlWtpHfZuZ
=4QFI
-----END PGP SIGNATURE-----

--Signature=_Thu__16_Feb_2012_12_38_03_+1100_dQp+EHQ2ECH2ggCo--
