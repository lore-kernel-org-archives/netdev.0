From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH for-next V1 1/2] net/mlx5: Fix mlx5 ifc cmd_hca_cap bad offsets
Date: Wed, 13 Apr 2016 19:11:03 +0300
Message-ID: <1460563864-22931-2-git-send-email-saeedm@mellanox.com>
References: <1460563864-22931-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Matan Barak <matanb@mellanox.com>,
	Leon Romanovsky <leonro@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
	Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:49660 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754095AbcDMQMU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2016 12:12:20 -0400
In-Reply-To: <1460563864-22931-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

All reserved fields after early_vf_enable are off by 1, since
early_vf_enable was not explicitly declared as array of size 1.

Reserved field before cqe_zip had a wrong size, it should
be 0x80 + 0x3f.

Fixes: b0844444590e ("net/mlx5_core: Introduce access function to read internal timer ")
Fixes: b4ff3a36d3e4 ("net/mlx5: Use offset based reserved field names in the IFC header file")
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Matan Barak <matanb@mellanox.com>
Acked-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 include/linux/mlx5/mlx5_ifc.h |  107 +++++++++++++++++++++--------------------
 1 files changed, 55 insertions(+), 52 deletions(-)

diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index c15b8a8..c300e74 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -750,21 +750,21 @@ struct mlx5_ifc_cmd_hca_cap_bits {
 	u8         ets[0x1];
 	u8         nic_flow_table[0x1];
 	u8         eswitch_flow_table[0x1];
-	u8	   early_vf_enable;
-	u8         reserved_at_1a8[0x2];
+	u8	   early_vf_enable[0x1];
+	u8         reserved_at_1a9[0x2];
 	u8         local_ca_ack_delay[0x5];
 	u8         reserved_at_1af[0x6];
 	u8         port_type[0x2];
 	u8         num_ports[0x8];
 
-	u8         reserved_at_1bf[0x3];
+	u8         reserved_at_1c0[0x3];
 	u8         log_max_msg[0x5];
-	u8         reserved_at_1c7[0x4];
+	u8         reserved_at_1c8[0x4];
 	u8         max_tc[0x4];
-	u8         reserved_at_1cf[0x6];
+	u8         reserved_at_1d0[0x6];
 	u8         rol_s[0x1];
 	u8         rol_g[0x1];
-	u8         reserved_at_1d7[0x1];
+	u8         reserved_at_1d8[0x1];
 	u8         wol_s[0x1];
 	u8         wol_g[0x1];
 	u8         wol_a[0x1];
@@ -774,47 +774,47 @@ struct mlx5_ifc_cmd_hca_cap_bits {
 	u8         wol_p[0x1];
 
 	u8         stat_rate_support[0x10];
-	u8         reserved_at_1ef[0xc];
+	u8         reserved_at_1f0[0xc];
 	u8         cqe_version[0x4];
 
 	u8         compact_address_vector[0x1];
 	u8         reserved_at_200[0x3];
 	u8         ipoib_basic_offloads[0x1];
-	u8         reserved_at_204[0xa];
+	u8         reserved_at_205[0xa];
 	u8         drain_sigerr[0x1];
 	u8         cmdif_checksum[0x2];
 	u8         sigerr_cqe[0x1];
-	u8         reserved_at_212[0x1];
+	u8         reserved_at_213[0x1];
 	u8         wq_signature[0x1];
 	u8         sctr_data_cqe[0x1];
-	u8         reserved_at_215[0x1];
+	u8         reserved_at_216[0x1];
 	u8         sho[0x1];
 	u8         tph[0x1];
 	u8         rf[0x1];
 	u8         dct[0x1];
-	u8         reserved_at_21a[0x1];
+	u8         reserved_at_21b[0x1];
 	u8         eth_net_offloads[0x1];
 	u8         roce[0x1];
 	u8         atomic[0x1];
-	u8         reserved_at_21e[0x1];
+	u8         reserved_at_21f[0x1];
 
 	u8         cq_oi[0x1];
 	u8         cq_resize[0x1];
 	u8         cq_moderation[0x1];
-	u8         reserved_at_222[0x3];
+	u8         reserved_at_223[0x3];
 	u8         cq_eq_remap[0x1];
 	u8         pg[0x1];
 	u8         block_lb_mc[0x1];
-	u8         reserved_at_228[0x1];
+	u8         reserved_at_229[0x1];
 	u8         scqe_break_moderation[0x1];
 	u8         reserved_at_22a[0x1];
 	u8         cd[0x1];
-	u8         reserved_at_22c[0x1];
+	u8         reserved_at_22d[0x1];
 	u8         apm[0x1];
 	u8         vector_calc[0x1];
 	u8         reserved_at_22f[0x1];
 	u8	   imaicl[0x1];
-	u8         reserved_at_231[0x4];
+	u8         reserved_at_232[0x4];
 	u8         qkv[0x1];
 	u8         pkv[0x1];
 	u8         set_deth_sqpn[0x1];
@@ -824,98 +824,101 @@ struct mlx5_ifc_cmd_hca_cap_bits {
 	u8         uc[0x1];
 	u8         rc[0x1];
 
-	u8         reserved_at_23f[0xa];
+	u8         reserved_at_240[0xa];
 	u8         uar_sz[0x6];
-	u8         reserved_at_24f[0x8];
+	u8         reserved_at_250[0x8];
 	u8         log_pg_sz[0x8];
 
 	u8         bf[0x1];
-	u8         reserved_at_260[0x1];
+	u8         reserved_at_261[0x1];
 	u8         pad_tx_eth_packet[0x1];
-	u8         reserved_at_262[0x8];
+	u8         reserved_at_263[0x8];
 	u8         log_bf_reg_size[0x5];
-	u8         reserved_at_26f[0x10];
+	u8         reserved_at_270[0x10];
 
-	u8         reserved_at_27f[0x10];
+	u8         reserved_at_280[0x10];
 	u8         max_wqe_sz_sq[0x10];
 
-	u8         reserved_at_29f[0x10];
+	u8         reserved_at_2a0[0x10];
 	u8         max_wqe_sz_rq[0x10];
 
-	u8         reserved_at_2bf[0x10];
+	u8         reserved_at_2c0[0x10];
 	u8         max_wqe_sz_sq_dc[0x10];
 
-	u8         reserved_at_2df[0x7];
+	u8         reserved_at_2e0[0x7];
 	u8         max_qp_mcg[0x19];
 
-	u8         reserved_at_2ff[0x18];
+	u8         reserved_at_300[0x18];
 	u8         log_max_mcg[0x8];
 
-	u8         reserved_at_31f[0x3];
+	u8         reserved_at_320[0x3];
 	u8         log_max_transport_domain[0x5];
-	u8         reserved_at_327[0x3];
+	u8         reserved_at_328[0x3];
 	u8         log_max_pd[0x5];
-	u8         reserved_at_32f[0xb];
+	u8         reserved_at_330[0xb];
 	u8         log_max_xrcd[0x5];
 
-	u8         reserved_at_33f[0x20];
+	u8         reserved_at_340[0x20];
 
-	u8         reserved_at_35f[0x3];
+	u8         reserved_at_360[0x3];
 	u8         log_max_rq[0x5];
-	u8         reserved_at_367[0x3];
+	u8         reserved_at_368[0x3];
 	u8         log_max_sq[0x5];
-	u8         reserved_at_36f[0x3];
+	u8         reserved_at_370[0x3];
 	u8         log_max_tir[0x5];
-	u8         reserved_at_377[0x3];
+	u8         reserved_at_378[0x3];
 	u8         log_max_tis[0x5];
 
 	u8         basic_cyclic_rcv_wqe[0x1];
-	u8         reserved_at_380[0x2];
+	u8         reserved_at_381[0x2];
 	u8         log_max_rmp[0x5];
-	u8         reserved_at_387[0x3];
+	u8         reserved_at_388[0x3];
 	u8         log_max_rqt[0x5];
-	u8         reserved_at_38f[0x3];
+	u8         reserved_at_390[0x3];
 	u8         log_max_rqt_size[0x5];
-	u8         reserved_at_397[0x3];
+	u8         reserved_at_398[0x3];
 	u8         log_max_tis_per_sq[0x5];
 
-	u8         reserved_at_39f[0x3];
+	u8         reserved_at_3a0[0x3];
 	u8         log_max_stride_sz_rq[0x5];
-	u8         reserved_at_3a7[0x3];
+	u8         reserved_at_3a8[0x3];
 	u8         log_min_stride_sz_rq[0x5];
-	u8         reserved_at_3af[0x3];
+	u8         reserved_at_3b0[0x3];
 	u8         log_max_stride_sz_sq[0x5];
-	u8         reserved_at_3b7[0x3];
+	u8         reserved_at_3b8[0x3];
 	u8         log_min_stride_sz_sq[0x5];
 
-	u8         reserved_at_3bf[0x1b];
+	u8         reserved_at_3c0[0x1b];
 	u8         log_max_wq_sz[0x5];
 
 	u8         nic_vport_change_event[0x1];
-	u8         reserved_at_3e0[0xa];
+	u8         reserved_at_3e1[0xa];
 	u8         log_max_vlan_list[0x5];
-	u8         reserved_at_3ef[0x3];
+	u8         reserved_at_3f0[0x3];
 	u8         log_max_current_mc_list[0x5];
-	u8         reserved_at_3f7[0x3];
+	u8         reserved_at_3f8[0x3];
 	u8         log_max_current_uc_list[0x5];
 
-	u8         reserved_at_3ff[0x80];
+	u8         reserved_at_400[0x80];
 
-	u8         reserved_at_47f[0x3];
+	u8         reserved_at_480[0x3];
 	u8         log_max_l2_table[0x5];
-	u8         reserved_at_487[0x8];
+	u8         reserved_at_488[0x8];
 	u8         log_uar_page_sz[0x10];
 
-	u8         reserved_at_49f[0x20];
+	u8         reserved_at_4a0[0x20];
 	u8         device_frequency_mhz[0x20];
 	u8         device_frequency_khz[0x20];
-	u8         reserved_at_4ff[0x5f];
+
+	u8         reserved_at_500[0x80];
+
+	u8         reserved_at_580[0x3f];
 	u8         cqe_zip[0x1];
 
 	u8         cqe_zip_timeout[0x10];
 	u8         cqe_zip_max_num[0x10];
 
-	u8         reserved_at_57f[0x220];
+	u8         reserved_at_5e0[0x220];
 };
 
 enum mlx5_flow_destination_type {
-- 
1.7.1
