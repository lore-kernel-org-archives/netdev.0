From: ravinandan.arakali@neterion.com
Subject: [KJ] [PATCH 2.6.12-rc1-bk1 1/3] S2io: Statistics fix
Date: Tue, 29 Mar 2005 13:54:29 -0800 (PST)
Message-ID: <20050329215429.DCFDE5D9A0@linux.site>
Content-Type: multipart/mixed; boundary="===============33872012382609462=="
Cc: raghavendra.koushik@neterion.com, ravinandan.arakali@neterion.com,
   leonid.grossman@neterion.com, rapuru.sriram@neterion.com
Return-path: <kernel-janitors-bounces@lists.osdl.org>
To: jgarzik@pobox.com, netdev@oss.sgi.com, kernel-janitors@lists.osdl.org
List-Unsubscribe: <http://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/kernel-janitors>
List-Post: <mailto:kernel-janitors@lists.osdl.org>
List-Help: <mailto:kernel-janitors-request@lists.osdl.org?subject=help>
List-Subscribe: <http://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=subscribe>
Sender: kernel-janitors-bounces@lists.osdl.org
Errors-To: kernel-janitors-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

--===============33872012382609462==

Hello,
Below patch fixes the statistics problem on big-endian systems(such
as IBM PPC).
Basically, the problem was "ethtool -s" was reporting huge values
on counters like no. of Tx frames, no. of Rx packets etc.
The fix has been tested on little-endian and big-endian systems.

Thanks,
Ravi

Signed-off-by: Ravinandan Arakali <ravinandan.arakali@neterion.com>
---
diff -urN 2.6.12-rc1-bk1/drivers/net/s2io.c statsfix1/drivers/net/s2io.c
--- 2.6.12-rc1-bk1/drivers/net/s2io.c	2005-03-25 05:28:40.000000000 -0800
+++ statsfix1/drivers/net/s2io.c	2005-03-25 05:53:57.000000000 -0800
@@ -3920,45 +3920,45 @@
 	nic_t *sp = dev->priv;
 	StatInfo_t *stat_info = sp->mac_control.stats_info;
 
-	tmp_stats[i++] = stat_info->tmac_frms;
-	tmp_stats[i++] = stat_info->tmac_data_octets;
-	tmp_stats[i++] = stat_info->tmac_drop_frms;
-	tmp_stats[i++] = stat_info->tmac_mcst_frms;
-	tmp_stats[i++] = stat_info->tmac_bcst_frms;
-	tmp_stats[i++] = stat_info->tmac_pause_ctrl_frms;
-	tmp_stats[i++] = stat_info->tmac_any_err_frms;
-	tmp_stats[i++] = stat_info->tmac_vld_ip_octets;
-	tmp_stats[i++] = stat_info->tmac_vld_ip;
-	tmp_stats[i++] = stat_info->tmac_drop_ip;
-	tmp_stats[i++] = stat_info->tmac_icmp;
-	tmp_stats[i++] = stat_info->tmac_rst_tcp;
-	tmp_stats[i++] = stat_info->tmac_tcp;
-	tmp_stats[i++] = stat_info->tmac_udp;
-	tmp_stats[i++] = stat_info->rmac_vld_frms;
-	tmp_stats[i++] = stat_info->rmac_data_octets;
-	tmp_stats[i++] = stat_info->rmac_fcs_err_frms;
-	tmp_stats[i++] = stat_info->rmac_drop_frms;
-	tmp_stats[i++] = stat_info->rmac_vld_mcst_frms;
-	tmp_stats[i++] = stat_info->rmac_vld_bcst_frms;
-	tmp_stats[i++] = stat_info->rmac_in_rng_len_err_frms;
-	tmp_stats[i++] = stat_info->rmac_long_frms;
-	tmp_stats[i++] = stat_info->rmac_pause_ctrl_frms;
-	tmp_stats[i++] = stat_info->rmac_discarded_frms;
-	tmp_stats[i++] = stat_info->rmac_usized_frms;
-	tmp_stats[i++] = stat_info->rmac_osized_frms;
-	tmp_stats[i++] = stat_info->rmac_frag_frms;
-	tmp_stats[i++] = stat_info->rmac_jabber_frms;
-	tmp_stats[i++] = stat_info->rmac_ip;
-	tmp_stats[i++] = stat_info->rmac_ip_octets;
-	tmp_stats[i++] = stat_info->rmac_hdr_err_ip;
-	tmp_stats[i++] = stat_info->rmac_drop_ip;
-	tmp_stats[i++] = stat_info->rmac_icmp;
-	tmp_stats[i++] = stat_info->rmac_tcp;
-	tmp_stats[i++] = stat_info->rmac_udp;
-	tmp_stats[i++] = stat_info->rmac_err_drp_udp;
-	tmp_stats[i++] = stat_info->rmac_pause_cnt;
-	tmp_stats[i++] = stat_info->rmac_accepted_ip;
-	tmp_stats[i++] = stat_info->rmac_err_tcp;
+	tmp_stats[i++] = le32_to_cpu(stat_info->tmac_frms);
+	tmp_stats[i++] = le32_to_cpu(stat_info->tmac_data_octets);
+	tmp_stats[i++] = le64_to_cpu(stat_info->tmac_drop_frms);
+	tmp_stats[i++] = le32_to_cpu(stat_info->tmac_mcst_frms);
+	tmp_stats[i++] = le32_to_cpu(stat_info->tmac_bcst_frms);
+	tmp_stats[i++] = le64_to_cpu(stat_info->tmac_pause_ctrl_frms);
+	tmp_stats[i++] = le32_to_cpu(stat_info->tmac_any_err_frms);
+	tmp_stats[i++] = le64_to_cpu(stat_info->tmac_vld_ip_octets);
+	tmp_stats[i++] = le32_to_cpu(stat_info->tmac_vld_ip);
+	tmp_stats[i++] = le32_to_cpu(stat_info->tmac_drop_ip);
+	tmp_stats[i++] = le32_to_cpu(stat_info->tmac_icmp);
+	tmp_stats[i++] = le32_to_cpu(stat_info->tmac_rst_tcp);
+	tmp_stats[i++] = le64_to_cpu(stat_info->tmac_tcp);
+	tmp_stats[i++] = le32_to_cpu(stat_info->tmac_udp);
+	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_vld_frms);
+	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_data_octets);
+	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_fcs_err_frms);
+	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_drop_frms);
+	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_vld_mcst_frms);
+	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_vld_bcst_frms);
+	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_in_rng_len_err_frms);
+	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_long_frms);
+	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_pause_ctrl_frms);
+	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_discarded_frms);
+	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_usized_frms);
+	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_osized_frms);
+	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_frag_frms);
+	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_jabber_frms);
+	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_ip);
+	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ip_octets);
+	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_hdr_err_ip);
+	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_drop_ip);
+	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_icmp);
+	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_tcp);
+	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_udp);
+	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_err_drp_udp);
+	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_pause_cnt);
+	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_accepted_ip);
+	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_err_tcp);
 }
 
 static int s2io_ethtool_get_regs_len(struct net_device *dev)
diff -urN 2.6.12-rc1-bk1/drivers/net/s2io.h statsfix1/drivers/net/s2io.h
--- 2.6.12-rc1-bk1/drivers/net/s2io.h	2005-03-25 05:28:40.000000000 -0800
+++ statsfix1/drivers/net/s2io.h	2005-03-25 05:56:40.000000000 -0800
@@ -73,121 +73,6 @@
 
 /* The statistics block of Xena */
 typedef struct stat_block {
-#ifdef  __BIG_ENDIAN
-/* Tx MAC statistics counters. */
-	u32 tmac_frms;
-	u32 tmac_data_octets;
-	u64 tmac_drop_frms;
-	u32 tmac_mcst_frms;
-	u32 tmac_bcst_frms;
-	u64 tmac_pause_ctrl_frms;
-	u32 tmac_ttl_octets;
-	u32 tmac_ucst_frms;
-	u32 tmac_nucst_frms;
-	u32 tmac_any_err_frms;
-	u64 tmac_ttl_less_fb_octets;
-	u64 tmac_vld_ip_octets;
-	u32 tmac_vld_ip;
-	u32 tmac_drop_ip;
-	u32 tmac_icmp;
-	u32 tmac_rst_tcp;
-	u64 tmac_tcp;
-	u32 tmac_udp;
-	u32 reserved_0;
-
-/* Rx MAC Statistics counters. */
-	u32 rmac_vld_frms;
-	u32 rmac_data_octets;
-	u64 rmac_fcs_err_frms;
-	u64 rmac_drop_frms;
-	u32 rmac_vld_mcst_frms;
-	u32 rmac_vld_bcst_frms;
-	u32 rmac_in_rng_len_err_frms;
-	u32 rmac_out_rng_len_err_frms;
-	u64 rmac_long_frms;
-	u64 rmac_pause_ctrl_frms;
-	u64 rmac_unsup_ctrl_frms;
-	u32 rmac_ttl_octets;
-	u32 rmac_accepted_ucst_frms;
-	u32 rmac_accepted_nucst_frms;
-	u32 rmac_discarded_frms;
-	u32 rmac_drop_events;
-	u32 reserved_1;
-	u64 rmac_ttl_less_fb_octets;
-	u64 rmac_ttl_frms;
-	u64 reserved_2;
-	u32 reserved_3;
-	u32 rmac_usized_frms;
-	u32 rmac_osized_frms;
-	u32 rmac_frag_frms;
-	u32 rmac_jabber_frms;
-	u32 reserved_4;
-	u64 rmac_ttl_64_frms;
-	u64 rmac_ttl_65_127_frms;
-	u64 reserved_5;
-	u64 rmac_ttl_128_255_frms;
-	u64 rmac_ttl_256_511_frms;
-	u64 reserved_6;
-	u64 rmac_ttl_512_1023_frms;
-	u64 rmac_ttl_1024_1518_frms;
-	u32 reserved_7;
-	u32 rmac_ip;
-	u64 rmac_ip_octets;
-	u32 rmac_hdr_err_ip;
-	u32 rmac_drop_ip;
-	u32 rmac_icmp;
-	u32 reserved_8;
-	u64 rmac_tcp;
-	u32 rmac_udp;
-	u32 rmac_err_drp_udp;
-	u64 rmac_xgmii_err_sym;
-	u64 rmac_frms_q0;
-	u64 rmac_frms_q1;
-	u64 rmac_frms_q2;
-	u64 rmac_frms_q3;
-	u64 rmac_frms_q4;
-	u64 rmac_frms_q5;
-	u64 rmac_frms_q6;
-	u64 rmac_frms_q7;
-	u16 rmac_full_q0;
-	u16 rmac_full_q1;
-	u16 rmac_full_q2;
-	u16 rmac_full_q3;
-	u16 rmac_full_q4;
-	u16 rmac_full_q5;
-	u16 rmac_full_q6;
-	u16 rmac_full_q7;
-	u32 rmac_pause_cnt;
-	u32 reserved_9;
-	u64 rmac_xgmii_data_err_cnt;
-	u64 rmac_xgmii_ctrl_err_cnt;
-	u32 rmac_accepted_ip;
-	u32 rmac_err_tcp;
-
-/* PCI/PCI-X Read transaction statistics. */
-	u32 rd_req_cnt;
-	u32 new_rd_req_cnt;
-	u32 new_rd_req_rtry_cnt;
-	u32 rd_rtry_cnt;
-	u32 wr_rtry_rd_ack_cnt;
-
-/* PCI/PCI-X write transaction statistics. */
-	u32 wr_req_cnt;
-	u32 new_wr_req_cnt;
-	u32 new_wr_req_rtry_cnt;
-	u32 wr_rtry_cnt;
-	u32 wr_disc_cnt;
-	u32 rd_rtry_wr_ack_cnt;
-
-/*	DMA Transaction statistics. */
-	u32 txp_wr_cnt;
-	u32 txd_rd_cnt;
-	u32 txd_wr_cnt;
-	u32 rxd_rd_cnt;
-	u32 rxd_wr_cnt;
-	u32 txf_rd_cnt;
-	u32 rxf_wr_cnt;
-#else
 /* Tx MAC statistics counters. */
 	u32 tmac_data_octets;
 	u32 tmac_frms;
@@ -301,7 +186,6 @@
 	u32 rxd_rd_cnt;
 	u32 rxf_wr_cnt;
 	u32 txf_rd_cnt;
-#endif
 } StatInfo_t;
 
 /* Structures representing different init time configuration

--===============33872012382609462==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

_______________________________________________
Kernel-janitors mailing list
Kernel-janitors@lists.osdl.org
http://lists.osdl.org/mailman/listinfo/kernel-janitors

--===============33872012382609462==--
