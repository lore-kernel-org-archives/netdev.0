From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/6] mlxsw: reg: Use helper macro to define registers
Date: Fri, 21 Oct 2016 16:07:20 +0200
Message-ID: <1477058843-9981-4-git-send-email-jiri@resnulli.us>
References: <1477058843-9981-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:33227 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755693AbcJUOHc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 10:07:32 -0400
Received: by mail-lf0-f66.google.com with SMTP id l131so5839795lfl.0
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 07:07:31 -0700 (PDT)
In-Reply-To: <1477058843-9981-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Save some code and also prepare to easily carry name in string form.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Acked-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 306 +++++++-----------------------
 1 file changed, 66 insertions(+), 240 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 6460c72..770dbb8 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -50,6 +50,12 @@ struct mlxsw_reg_info {
 	u16 len; /* In u8 */
 };
 
+#define MLXSW_REG_DEFINE(_name, _id, _len)				\
+static const struct mlxsw_reg_info mlxsw_reg_##_name = {		\
+	.id = _id,							\
+	.len = _len,							\
+}
+
 #define MLXSW_REG(type) (&mlxsw_reg_##type)
 #define MLXSW_REG_LEN(type) MLXSW_REG(type)->len
 #define MLXSW_REG_ZERO(type, payload) memset(payload, 0, MLXSW_REG(type)->len)
@@ -61,10 +67,7 @@ struct mlxsw_reg_info {
 #define MLXSW_REG_SGCR_ID 0x2000
 #define MLXSW_REG_SGCR_LEN 0x10
 
-static const struct mlxsw_reg_info mlxsw_reg_sgcr = {
-	.id = MLXSW_REG_SGCR_ID,
-	.len = MLXSW_REG_SGCR_LEN,
-};
+MLXSW_REG_DEFINE(sgcr, MLXSW_REG_SGCR_ID, MLXSW_REG_SGCR_LEN);
 
 /* reg_sgcr_llb
  * Link Local Broadcast (Default=0)
@@ -87,10 +90,7 @@ static inline void mlxsw_reg_sgcr_pack(char *payload, bool llb)
 #define MLXSW_REG_SPAD_ID 0x2002
 #define MLXSW_REG_SPAD_LEN 0x10
 
-static const struct mlxsw_reg_info mlxsw_reg_spad = {
-	.id = MLXSW_REG_SPAD_ID,
-	.len = MLXSW_REG_SPAD_LEN,
-};
+MLXSW_REG_DEFINE(spad, MLXSW_REG_SPAD_ID, MLXSW_REG_SPAD_LEN);
 
 /* reg_spad_base_mac
  * Base MAC address for the switch partitions.
@@ -109,10 +109,7 @@ MLXSW_ITEM_BUF(reg, spad, base_mac, 0x02, 6);
 #define MLXSW_REG_SMID_ID 0x2007
 #define MLXSW_REG_SMID_LEN 0x240
 
-static const struct mlxsw_reg_info mlxsw_reg_smid = {
-	.id = MLXSW_REG_SMID_ID,
-	.len = MLXSW_REG_SMID_LEN,
-};
+MLXSW_REG_DEFINE(smid, MLXSW_REG_SMID_ID, MLXSW_REG_SMID_LEN);
 
 /* reg_smid_swid
  * Switch partition ID.
@@ -156,10 +153,7 @@ static inline void mlxsw_reg_smid_pack(char *payload, u16 mid,
 #define MLXSW_REG_SSPR_ID 0x2008
 #define MLXSW_REG_SSPR_LEN 0x8
 
-static const struct mlxsw_reg_info mlxsw_reg_sspr = {
-	.id = MLXSW_REG_SSPR_ID,
-	.len = MLXSW_REG_SSPR_LEN,
-};
+MLXSW_REG_DEFINE(sspr, MLXSW_REG_SSPR_ID, MLXSW_REG_SSPR_LEN);
 
 /* reg_sspr_m
  * Master - if set, then the record describes the master system port.
@@ -215,10 +209,7 @@ static inline void mlxsw_reg_sspr_pack(char *payload, u8 local_port)
 #define MLXSW_REG_SFDAT_ID 0x2009
 #define MLXSW_REG_SFDAT_LEN 0x8
 
-static const struct mlxsw_reg_info mlxsw_reg_sfdat = {
-	.id = MLXSW_REG_SFDAT_ID,
-	.len = MLXSW_REG_SFDAT_LEN,
-};
+MLXSW_REG_DEFINE(sfdat, MLXSW_REG_SFDAT_ID, MLXSW_REG_SFDAT_LEN);
 
 /* reg_sfdat_swid
  * Switch partition ID.
@@ -256,10 +247,7 @@ static inline void mlxsw_reg_sfdat_pack(char *payload, u32 age_time)
 #define MLXSW_REG_SFD_LEN (MLXSW_REG_SFD_BASE_LEN +	\
 			   MLXSW_REG_SFD_REC_LEN * MLXSW_REG_SFD_REC_MAX_COUNT)
 
-static const struct mlxsw_reg_info mlxsw_reg_sfd = {
-	.id = MLXSW_REG_SFD_ID,
-	.len = MLXSW_REG_SFD_LEN,
-};
+MLXSW_REG_DEFINE(sfd, MLXSW_REG_SFD_ID, MLXSW_REG_SFD_LEN);
 
 /* reg_sfd_swid
  * Switch partition ID for queries. Reserved on Write.
@@ -580,10 +568,7 @@ mlxsw_reg_sfd_mc_pack(char *payload, int rec_index,
 #define MLXSW_REG_SFN_LEN (MLXSW_REG_SFN_BASE_LEN +	\
 			   MLXSW_REG_SFN_REC_LEN * MLXSW_REG_SFN_REC_MAX_COUNT)
 
-static const struct mlxsw_reg_info mlxsw_reg_sfn = {
-	.id = MLXSW_REG_SFN_ID,
-	.len = MLXSW_REG_SFN_LEN,
-};
+MLXSW_REG_DEFINE(sfn, MLXSW_REG_SFN_ID, MLXSW_REG_SFN_LEN);
 
 /* reg_sfn_swid
  * Switch partition ID.
@@ -701,10 +686,7 @@ static inline void mlxsw_reg_sfn_mac_lag_unpack(char *payload, int rec_index,
 #define MLXSW_REG_SPMS_ID 0x200D
 #define MLXSW_REG_SPMS_LEN 0x404
 
-static const struct mlxsw_reg_info mlxsw_reg_spms = {
-	.id = MLXSW_REG_SPMS_ID,
-	.len = MLXSW_REG_SPMS_LEN,
-};
+MLXSW_REG_DEFINE(spms, MLXSW_REG_SPMS_ID, MLXSW_REG_SPMS_LEN);
 
 /* reg_spms_local_port
  * Local port number.
@@ -748,10 +730,7 @@ static inline void mlxsw_reg_spms_vid_pack(char *payload, u16 vid,
 #define MLXSW_REG_SPVID_ID 0x200E
 #define MLXSW_REG_SPVID_LEN 0x08
 
-static const struct mlxsw_reg_info mlxsw_reg_spvid = {
-	.id = MLXSW_REG_SPVID_ID,
-	.len = MLXSW_REG_SPVID_LEN,
-};
+MLXSW_REG_DEFINE(spvid, MLXSW_REG_SPVID_ID, MLXSW_REG_SPVID_LEN);
 
 /* reg_spvid_local_port
  * Local port number.
@@ -792,10 +771,7 @@ static inline void mlxsw_reg_spvid_pack(char *payload, u8 local_port, u16 pvid)
 #define MLXSW_REG_SPVM_LEN (MLXSW_REG_SPVM_BASE_LEN +	\
 		    MLXSW_REG_SPVM_REC_LEN * MLXSW_REG_SPVM_REC_MAX_COUNT)
 
-static const struct mlxsw_reg_info mlxsw_reg_spvm = {
-	.id = MLXSW_REG_SPVM_ID,
-	.len = MLXSW_REG_SPVM_LEN,
-};
+MLXSW_REG_DEFINE(spvm, MLXSW_REG_SPVM_ID, MLXSW_REG_SPVM_LEN);
 
 /* reg_spvm_pt
  * Priority tagged. If this bit is set, packets forwarded to the port with
@@ -891,10 +867,7 @@ static inline void mlxsw_reg_spvm_pack(char *payload, u8 local_port,
 #define MLXSW_REG_SPAFT_ID 0x2010
 #define MLXSW_REG_SPAFT_LEN 0x08
 
-static const struct mlxsw_reg_info mlxsw_reg_spaft = {
-	.id = MLXSW_REG_SPAFT_ID,
-	.len = MLXSW_REG_SPAFT_LEN,
-};
+MLXSW_REG_DEFINE(spaft, MLXSW_REG_SPAFT_ID, MLXSW_REG_SPAFT_LEN);
 
 /* reg_spaft_local_port
  * Local port number.
@@ -947,10 +920,7 @@ static inline void mlxsw_reg_spaft_pack(char *payload, u8 local_port,
 #define MLXSW_REG_SFGC_ID 0x2011
 #define MLXSW_REG_SFGC_LEN 0x10
 
-static const struct mlxsw_reg_info mlxsw_reg_sfgc = {
-	.id = MLXSW_REG_SFGC_ID,
-	.len = MLXSW_REG_SFGC_LEN,
-};
+MLXSW_REG_DEFINE(sfgc, MLXSW_REG_SFGC_ID, MLXSW_REG_SFGC_LEN);
 
 enum mlxsw_reg_sfgc_type {
 	MLXSW_REG_SFGC_TYPE_BROADCAST,
@@ -1045,10 +1015,7 @@ mlxsw_reg_sfgc_pack(char *payload, enum mlxsw_reg_sfgc_type type,
 #define MLXSW_REG_SFTR_ID 0x2012
 #define MLXSW_REG_SFTR_LEN 0x420
 
-static const struct mlxsw_reg_info mlxsw_reg_sftr = {
-	.id = MLXSW_REG_SFTR_ID,
-	.len = MLXSW_REG_SFTR_LEN,
-};
+MLXSW_REG_DEFINE(sftr, MLXSW_REG_SFTR_ID, MLXSW_REG_SFTR_LEN);
 
 /* reg_sftr_swid
  * Switch partition ID with which to associate the port.
@@ -1118,10 +1085,7 @@ static inline void mlxsw_reg_sftr_pack(char *payload,
 #define MLXSW_REG_SFDF_ID 0x2013
 #define MLXSW_REG_SFDF_LEN 0x14
 
-static const struct mlxsw_reg_info mlxsw_reg_sfdf = {
-	.id = MLXSW_REG_SFDF_ID,
-	.len = MLXSW_REG_SFDF_LEN,
-};
+MLXSW_REG_DEFINE(sfdf, MLXSW_REG_SFDF_ID, MLXSW_REG_SFDF_LEN);
 
 /* reg_sfdf_swid
  * Switch partition ID.
@@ -1205,10 +1169,7 @@ MLXSW_ITEM32(reg, sfdf, lag_fid_lag_id, 0x08, 0, 10);
 #define MLXSW_REG_SLDR_ID 0x2014
 #define MLXSW_REG_SLDR_LEN 0x0C /* counting in only one port in list */
 
-static const struct mlxsw_reg_info mlxsw_reg_sldr = {
-	.id = MLXSW_REG_SLDR_ID,
-	.len = MLXSW_REG_SLDR_LEN,
-};
+MLXSW_REG_DEFINE(sldr, MLXSW_REG_SLDR_ID, MLXSW_REG_SLDR_LEN);
 
 enum mlxsw_reg_sldr_op {
 	/* Indicates a creation of a new LAG-ID, lag_id must be valid */
@@ -1288,10 +1249,7 @@ static inline void mlxsw_reg_sldr_lag_remove_port_pack(char *payload, u8 lag_id,
 #define MLXSW_REG_SLCR_ID 0x2015
 #define MLXSW_REG_SLCR_LEN 0x10
 
-static const struct mlxsw_reg_info mlxsw_reg_slcr = {
-	.id = MLXSW_REG_SLCR_ID,
-	.len = MLXSW_REG_SLCR_LEN,
-};
+MLXSW_REG_DEFINE(slcr, MLXSW_REG_SLCR_ID, MLXSW_REG_SLCR_LEN);
 
 enum mlxsw_reg_slcr_pp {
 	/* Global Configuration (for all ports) */
@@ -1404,10 +1362,7 @@ static inline void mlxsw_reg_slcr_pack(char *payload, u16 lag_hash)
 #define MLXSW_REG_SLCOR_ID 0x2016
 #define MLXSW_REG_SLCOR_LEN 0x10
 
-static const struct mlxsw_reg_info mlxsw_reg_slcor = {
-	.id = MLXSW_REG_SLCOR_ID,
-	.len = MLXSW_REG_SLCOR_LEN,
-};
+MLXSW_REG_DEFINE(slcor, MLXSW_REG_SLCOR_ID, MLXSW_REG_SLCOR_LEN);
 
 enum mlxsw_reg_slcor_col {
 	/* Port is added with collector disabled */
@@ -1490,10 +1445,7 @@ static inline void mlxsw_reg_slcor_col_disable_pack(char *payload,
 #define MLXSW_REG_SPMLR_ID 0x2018
 #define MLXSW_REG_SPMLR_LEN 0x8
 
-static const struct mlxsw_reg_info mlxsw_reg_spmlr = {
-	.id = MLXSW_REG_SPMLR_ID,
-	.len = MLXSW_REG_SPMLR_LEN,
-};
+MLXSW_REG_DEFINE(spmlr, MLXSW_REG_SPMLR_ID, MLXSW_REG_SPMLR_LEN);
 
 /* reg_spmlr_local_port
  * Local port number.
@@ -1544,10 +1496,7 @@ static inline void mlxsw_reg_spmlr_pack(char *payload, u8 local_port,
 #define MLXSW_REG_SVFA_ID 0x201C
 #define MLXSW_REG_SVFA_LEN 0x10
 
-static const struct mlxsw_reg_info mlxsw_reg_svfa = {
-	.id = MLXSW_REG_SVFA_ID,
-	.len = MLXSW_REG_SVFA_LEN,
-};
+MLXSW_REG_DEFINE(svfa, MLXSW_REG_SVFA_ID, MLXSW_REG_SVFA_LEN);
 
 /* reg_svfa_swid
  * Switch partition ID.
@@ -1636,10 +1585,7 @@ static inline void mlxsw_reg_svfa_pack(char *payload, u8 local_port,
 #define MLXSW_REG_SVPE_ID 0x201E
 #define MLXSW_REG_SVPE_LEN 0x4
 
-static const struct mlxsw_reg_info mlxsw_reg_svpe = {
-	.id = MLXSW_REG_SVPE_ID,
-	.len = MLXSW_REG_SVPE_LEN,
-};
+MLXSW_REG_DEFINE(svpe, MLXSW_REG_SVPE_ID, MLXSW_REG_SVPE_LEN);
 
 /* reg_svpe_local_port
  * Local port number
@@ -1672,10 +1618,7 @@ static inline void mlxsw_reg_svpe_pack(char *payload, u8 local_port,
 #define MLXSW_REG_SFMR_ID 0x201F
 #define MLXSW_REG_SFMR_LEN 0x18
 
-static const struct mlxsw_reg_info mlxsw_reg_sfmr = {
-	.id = MLXSW_REG_SFMR_ID,
-	.len = MLXSW_REG_SFMR_LEN,
-};
+MLXSW_REG_DEFINE(sfmr, MLXSW_REG_SFMR_ID, MLXSW_REG_SFMR_LEN);
 
 enum mlxsw_reg_sfmr_op {
 	MLXSW_REG_SFMR_OP_CREATE_FID,
@@ -1762,10 +1705,7 @@ static inline void mlxsw_reg_sfmr_pack(char *payload,
 			      MLXSW_REG_SPVMLR_REC_LEN * \
 			      MLXSW_REG_SPVMLR_REC_MAX_COUNT)
 
-static const struct mlxsw_reg_info mlxsw_reg_spvmlr = {
-	.id = MLXSW_REG_SPVMLR_ID,
-	.len = MLXSW_REG_SPVMLR_LEN,
-};
+MLXSW_REG_DEFINE(spvmlr, MLXSW_REG_SPVMLR_ID, MLXSW_REG_SPVMLR_LEN);
 
 /* reg_spvmlr_local_port
  * Local ingress port.
@@ -1823,10 +1763,7 @@ static inline void mlxsw_reg_spvmlr_pack(char *payload, u8 local_port,
 #define MLXSW_REG_QTCT_ID 0x400A
 #define MLXSW_REG_QTCT_LEN 0x08
 
-static const struct mlxsw_reg_info mlxsw_reg_qtct = {
-	.id = MLXSW_REG_QTCT_ID,
-	.len = MLXSW_REG_QTCT_LEN,
-};
+MLXSW_REG_DEFINE(qtct, MLXSW_REG_QTCT_ID, MLXSW_REG_QTCT_LEN);
 
 /* reg_qtct_local_port
  * Local port number.
@@ -1875,10 +1812,7 @@ static inline void mlxsw_reg_qtct_pack(char *payload, u8 local_port,
 #define MLXSW_REG_QEEC_ID 0x400D
 #define MLXSW_REG_QEEC_LEN 0x1C
 
-static const struct mlxsw_reg_info mlxsw_reg_qeec = {
-	.id = MLXSW_REG_QEEC_ID,
-	.len = MLXSW_REG_QEEC_LEN,
-};
+MLXSW_REG_DEFINE(qeec, MLXSW_REG_QEEC_ID, MLXSW_REG_QEEC_LEN);
 
 /* reg_qeec_local_port
  * Local port number.
@@ -2000,10 +1934,7 @@ static inline void mlxsw_reg_qeec_pack(char *payload, u8 local_port,
 #define MLXSW_REG_PMLP_ID 0x5002
 #define MLXSW_REG_PMLP_LEN 0x40
 
-static const struct mlxsw_reg_info mlxsw_reg_pmlp = {
-	.id = MLXSW_REG_PMLP_ID,
-	.len = MLXSW_REG_PMLP_LEN,
-};
+MLXSW_REG_DEFINE(pmlp, MLXSW_REG_PMLP_ID, MLXSW_REG_PMLP_LEN);
 
 /* reg_pmlp_rxtx
  * 0 - Tx value is used for both Tx and Rx.
@@ -2059,10 +1990,7 @@ static inline void mlxsw_reg_pmlp_pack(char *payload, u8 local_port)
 #define MLXSW_REG_PMTU_ID 0x5003
 #define MLXSW_REG_PMTU_LEN 0x10
 
-static const struct mlxsw_reg_info mlxsw_reg_pmtu = {
-	.id = MLXSW_REG_PMTU_ID,
-	.len = MLXSW_REG_PMTU_LEN,
-};
+MLXSW_REG_DEFINE(pmtu, MLXSW_REG_PMTU_ID, MLXSW_REG_PMTU_LEN);
 
 /* reg_pmtu_local_port
  * Local port number.
@@ -2116,10 +2044,7 @@ static inline void mlxsw_reg_pmtu_pack(char *payload, u8 local_port,
 #define MLXSW_REG_PTYS_ID 0x5004
 #define MLXSW_REG_PTYS_LEN 0x40
 
-static const struct mlxsw_reg_info mlxsw_reg_ptys = {
-	.id = MLXSW_REG_PTYS_ID,
-	.len = MLXSW_REG_PTYS_LEN,
-};
+MLXSW_REG_DEFINE(ptys, MLXSW_REG_PTYS_ID, MLXSW_REG_PTYS_LEN);
 
 /* reg_ptys_local_port
  * Local port number.
@@ -2232,10 +2157,7 @@ static inline void mlxsw_reg_ptys_unpack(char *payload, u32 *p_eth_proto_cap,
 #define MLXSW_REG_PPAD_ID 0x5005
 #define MLXSW_REG_PPAD_LEN 0x10
 
-static const struct mlxsw_reg_info mlxsw_reg_ppad = {
-	.id = MLXSW_REG_PPAD_ID,
-	.len = MLXSW_REG_PPAD_LEN,
-};
+MLXSW_REG_DEFINE(ppad, MLXSW_REG_PPAD_ID, MLXSW_REG_PPAD_LEN);
 
 /* reg_ppad_single_base_mac
  * 0: base_mac, local port should be 0 and mac[7:0] is
@@ -2273,10 +2195,7 @@ static inline void mlxsw_reg_ppad_pack(char *payload, bool single_base_mac,
 #define MLXSW_REG_PAOS_ID 0x5006
 #define MLXSW_REG_PAOS_LEN 0x10
 
-static const struct mlxsw_reg_info mlxsw_reg_paos = {
-	.id = MLXSW_REG_PAOS_ID,
-	.len = MLXSW_REG_PAOS_LEN,
-};
+MLXSW_REG_DEFINE(paos, MLXSW_REG_PAOS_ID, MLXSW_REG_PAOS_LEN);
 
 /* reg_paos_swid
  * Switch partition ID with which to associate the port.
@@ -2356,10 +2275,7 @@ static inline void mlxsw_reg_paos_pack(char *payload, u8 local_port,
 #define MLXSW_REG_PFCC_ID 0x5007
 #define MLXSW_REG_PFCC_LEN 0x20
 
-static const struct mlxsw_reg_info mlxsw_reg_pfcc = {
-	.id = MLXSW_REG_PFCC_ID,
-	.len = MLXSW_REG_PFCC_LEN,
-};
+MLXSW_REG_DEFINE(pfcc, MLXSW_REG_PFCC_ID, MLXSW_REG_PFCC_LEN);
 
 /* reg_pfcc_local_port
  * Local port number.
@@ -2495,10 +2411,7 @@ static inline void mlxsw_reg_pfcc_pack(char *payload, u8 local_port)
 #define MLXSW_REG_PPCNT_ID 0x5008
 #define MLXSW_REG_PPCNT_LEN 0x100
 
-static const struct mlxsw_reg_info mlxsw_reg_ppcnt = {
-	.id = MLXSW_REG_PPCNT_ID,
-	.len = MLXSW_REG_PPCNT_LEN,
-};
+MLXSW_REG_DEFINE(ppcnt, MLXSW_REG_PPCNT_ID, MLXSW_REG_PPCNT_LEN);
 
 /* reg_ppcnt_swid
  * For HCA: must be always 0.
@@ -2768,10 +2681,7 @@ static inline void mlxsw_reg_ppcnt_pack(char *payload, u8 local_port,
 #define MLXSW_REG_PPTB_ID 0x500B
 #define MLXSW_REG_PPTB_LEN 0x10
 
-static const struct mlxsw_reg_info mlxsw_reg_pptb = {
-	.id = MLXSW_REG_PPTB_ID,
-	.len = MLXSW_REG_PPTB_LEN,
-};
+MLXSW_REG_DEFINE(pptb, MLXSW_REG_PPTB_ID, MLXSW_REG_PPTB_LEN);
 
 enum {
 	MLXSW_REG_PPTB_MM_UM,
@@ -2865,10 +2775,7 @@ static inline void mlxsw_reg_pptb_prio_to_buff_pack(char *payload, u8 prio,
 #define MLXSW_REG_PBMC_ID 0x500C
 #define MLXSW_REG_PBMC_LEN 0x6C
 
-static const struct mlxsw_reg_info mlxsw_reg_pbmc = {
-	.id = MLXSW_REG_PBMC_ID,
-	.len = MLXSW_REG_PBMC_LEN,
-};
+MLXSW_REG_DEFINE(pbmc, MLXSW_REG_PBMC_ID, MLXSW_REG_PBMC_LEN);
 
 /* reg_pbmc_local_port
  * Local port number.
@@ -2978,10 +2885,7 @@ static inline void mlxsw_reg_pbmc_lossless_buffer_pack(char *payload,
 #define MLXSW_REG_PSPA_ID 0x500D
 #define MLXSW_REG_PSPA_LEN 0x8
 
-static const struct mlxsw_reg_info mlxsw_reg_pspa = {
-	.id = MLXSW_REG_PSPA_ID,
-	.len = MLXSW_REG_PSPA_LEN,
-};
+MLXSW_REG_DEFINE(pspa, MLXSW_REG_PSPA_ID, MLXSW_REG_PSPA_LEN);
 
 /* reg_pspa_swid
  * Switch partition ID.
@@ -3017,10 +2921,7 @@ static inline void mlxsw_reg_pspa_pack(char *payload, u8 swid, u8 local_port)
 #define MLXSW_REG_HTGT_ID 0x7002
 #define MLXSW_REG_HTGT_LEN 0x100
 
-static const struct mlxsw_reg_info mlxsw_reg_htgt = {
-	.id = MLXSW_REG_HTGT_ID,
-	.len = MLXSW_REG_HTGT_LEN,
-};
+MLXSW_REG_DEFINE(htgt, MLXSW_REG_HTGT_ID, MLXSW_REG_HTGT_LEN);
 
 /* reg_htgt_swid
  * Switch partition ID.
@@ -3154,10 +3055,7 @@ static inline void mlxsw_reg_htgt_pack(char *payload,
 #define MLXSW_REG_HPKT_ID 0x7003
 #define MLXSW_REG_HPKT_LEN 0x10
 
-static const struct mlxsw_reg_info mlxsw_reg_hpkt = {
-	.id = MLXSW_REG_HPKT_ID,
-	.len = MLXSW_REG_HPKT_LEN,
-};
+MLXSW_REG_DEFINE(hpkt, MLXSW_REG_HPKT_ID, MLXSW_REG_HPKT_LEN);
 
 enum {
 	MLXSW_REG_HPKT_ACK_NOT_REQUIRED,
@@ -3256,10 +3154,7 @@ static inline void mlxsw_reg_hpkt_pack(char *payload, u8 action, u16 trap_id)
 #define MLXSW_REG_RGCR_ID 0x8001
 #define MLXSW_REG_RGCR_LEN 0x28
 
-static const struct mlxsw_reg_info mlxsw_reg_rgcr = {
-	.id = MLXSW_REG_RGCR_ID,
-	.len = MLXSW_REG_RGCR_LEN,
-};
+MLXSW_REG_DEFINE(rgcr, MLXSW_REG_RGCR_ID, MLXSW_REG_RGCR_LEN);
 
 /* reg_rgcr_ipv4_en
  * IPv4 router enable.
@@ -3330,10 +3225,7 @@ static inline void mlxsw_reg_rgcr_pack(char *payload, bool ipv4_en)
 #define MLXSW_REG_RITR_ID 0x8002
 #define MLXSW_REG_RITR_LEN 0x40
 
-static const struct mlxsw_reg_info mlxsw_reg_ritr = {
-	.id = MLXSW_REG_RITR_ID,
-	.len = MLXSW_REG_RITR_LEN,
-};
+MLXSW_REG_DEFINE(ritr, MLXSW_REG_RITR_ID, MLXSW_REG_RITR_LEN);
 
 /* reg_ritr_enable
  * Enables routing on the router interface.
@@ -3533,10 +3425,7 @@ static inline void mlxsw_reg_ritr_pack(char *payload, bool enable,
 #define MLXSW_REG_RATR_ID 0x8008
 #define MLXSW_REG_RATR_LEN 0x2C
 
-static const struct mlxsw_reg_info mlxsw_reg_ratr = {
-	.id = MLXSW_REG_RATR_ID,
-	.len = MLXSW_REG_RATR_LEN,
-};
+MLXSW_REG_DEFINE(ratr, MLXSW_REG_RATR_ID, MLXSW_REG_RATR_LEN);
 
 enum mlxsw_reg_ratr_op {
 	/* Read */
@@ -3663,10 +3552,7 @@ static inline void mlxsw_reg_ratr_eth_entry_pack(char *payload,
 #define MLXSW_REG_RALTA_ID 0x8010
 #define MLXSW_REG_RALTA_LEN 0x04
 
-static const struct mlxsw_reg_info mlxsw_reg_ralta = {
-	.id = MLXSW_REG_RALTA_ID,
-	.len = MLXSW_REG_RALTA_LEN,
-};
+MLXSW_REG_DEFINE(ralta, MLXSW_REG_RALTA_ID, MLXSW_REG_RALTA_LEN);
 
 /* reg_ralta_op
  * opcode (valid for Write, must be 0 on Read)
@@ -3718,10 +3604,7 @@ static inline void mlxsw_reg_ralta_pack(char *payload, bool alloc,
 #define MLXSW_REG_RALST_ID 0x8011
 #define MLXSW_REG_RALST_LEN 0x104
 
-static const struct mlxsw_reg_info mlxsw_reg_ralst = {
-	.id = MLXSW_REG_RALST_ID,
-	.len = MLXSW_REG_RALST_LEN,
-};
+MLXSW_REG_DEFINE(ralst, MLXSW_REG_RALST_ID, MLXSW_REG_RALST_LEN);
 
 /* reg_ralst_root_bin
  * The bin number of the root bin.
@@ -3788,10 +3671,7 @@ static inline void mlxsw_reg_ralst_bin_pack(char *payload, u8 bin_number,
 #define MLXSW_REG_RALTB_ID 0x8012
 #define MLXSW_REG_RALTB_LEN 0x04
 
-static const struct mlxsw_reg_info mlxsw_reg_raltb = {
-	.id = MLXSW_REG_RALTB_ID,
-	.len = MLXSW_REG_RALTB_LEN,
-};
+MLXSW_REG_DEFINE(raltb, MLXSW_REG_RALTB_ID, MLXSW_REG_RALTB_LEN);
 
 /* reg_raltb_virtual_router
  * Virtual Router ID
@@ -3832,10 +3712,7 @@ static inline void mlxsw_reg_raltb_pack(char *payload, u16 virtual_router,
 #define MLXSW_REG_RALUE_ID 0x8013
 #define MLXSW_REG_RALUE_LEN 0x38
 
-static const struct mlxsw_reg_info mlxsw_reg_ralue = {
-	.id = MLXSW_REG_RALUE_ID,
-	.len = MLXSW_REG_RALUE_LEN,
-};
+MLXSW_REG_DEFINE(ralue, MLXSW_REG_RALUE_ID, MLXSW_REG_RALUE_LEN);
 
 /* reg_ralue_protocol
  * Protocol.
@@ -4095,10 +3972,7 @@ mlxsw_reg_ralue_act_ip2me_pack(char *payload)
 #define MLXSW_REG_RAUHT_ID 0x8014
 #define MLXSW_REG_RAUHT_LEN 0x74
 
-static const struct mlxsw_reg_info mlxsw_reg_rauht = {
-	.id = MLXSW_REG_RAUHT_ID,
-	.len = MLXSW_REG_RAUHT_LEN,
-};
+MLXSW_REG_DEFINE(rauht, MLXSW_REG_RAUHT_ID, MLXSW_REG_RAUHT_LEN);
 
 enum mlxsw_reg_rauht_type {
 	MLXSW_REG_RAUHT_TYPE_IPV4,
@@ -4234,10 +4108,7 @@ static inline void mlxsw_reg_rauht_pack4(char *payload,
 #define MLXSW_REG_RALEU_ID 0x8015
 #define MLXSW_REG_RALEU_LEN 0x28
 
-static const struct mlxsw_reg_info mlxsw_reg_raleu = {
-	.id = MLXSW_REG_RALEU_ID,
-	.len = MLXSW_REG_RALEU_LEN,
-};
+MLXSW_REG_DEFINE(raleu, MLXSW_REG_RALEU_ID, MLXSW_REG_RALEU_LEN);
 
 /* reg_raleu_protocol
  * Protocol.
@@ -4309,10 +4180,7 @@ static inline void mlxsw_reg_raleu_pack(char *payload,
 		MLXSW_REG_RAUHTD_REC_MAX_NUM * MLXSW_REG_RAUHTD_REC_LEN)
 #define MLXSW_REG_RAUHTD_IPV4_ENT_PER_REC 4
 
-static const struct mlxsw_reg_info mlxsw_reg_rauhtd = {
-	.id = MLXSW_REG_RAUHTD_ID,
-	.len = MLXSW_REG_RAUHTD_LEN,
-};
+MLXSW_REG_DEFINE(rauhtd, MLXSW_REG_RAUHTD_ID, MLXSW_REG_RAUHTD_LEN);
 
 #define MLXSW_REG_RAUHTD_FILTER_A BIT(0)
 #define MLXSW_REG_RAUHTD_FILTER_RIF BIT(3)
@@ -4444,10 +4312,7 @@ static inline void mlxsw_reg_rauhtd_ent_ipv4_unpack(char *payload,
 #define MLXSW_REG_MFCR_ID 0x9001
 #define MLXSW_REG_MFCR_LEN 0x08
 
-static const struct mlxsw_reg_info mlxsw_reg_mfcr = {
-	.id = MLXSW_REG_MFCR_ID,
-	.len = MLXSW_REG_MFCR_LEN,
-};
+MLXSW_REG_DEFINE(mfcr, MLXSW_REG_MFCR_ID, MLXSW_REG_MFCR_LEN);
 
 enum mlxsw_reg_mfcr_pwm_frequency {
 	MLXSW_REG_MFCR_PWM_FEQ_11HZ = 0x00,
@@ -4507,10 +4372,7 @@ mlxsw_reg_mfcr_unpack(char *payload,
 #define MLXSW_REG_MFSC_ID 0x9002
 #define MLXSW_REG_MFSC_LEN 0x08
 
-static const struct mlxsw_reg_info mlxsw_reg_mfsc = {
-	.id = MLXSW_REG_MFSC_ID,
-	.len = MLXSW_REG_MFSC_LEN,
-};
+MLXSW_REG_DEFINE(mfsc, MLXSW_REG_MFSC_ID, MLXSW_REG_MFSC_LEN);
 
 /* reg_mfsc_pwm
  * Fan pwm to control / monitor.
@@ -4541,10 +4403,7 @@ static inline void mlxsw_reg_mfsc_pack(char *payload, u8 pwm,
 #define MLXSW_REG_MFSM_ID 0x9003
 #define MLXSW_REG_MFSM_LEN 0x08
 
-static const struct mlxsw_reg_info mlxsw_reg_mfsm = {
-	.id = MLXSW_REG_MFSM_ID,
-	.len = MLXSW_REG_MFSM_LEN,
-};
+MLXSW_REG_DEFINE(mfsm, MLXSW_REG_MFSM_ID, MLXSW_REG_MFSM_LEN);
 
 /* reg_mfsm_tacho
  * Fan tachometer index.
@@ -4572,10 +4431,7 @@ static inline void mlxsw_reg_mfsm_pack(char *payload, u8 tacho)
 #define MLXSW_REG_MTCAP_ID 0x9009
 #define MLXSW_REG_MTCAP_LEN 0x08
 
-static const struct mlxsw_reg_info mlxsw_reg_mtcap = {
-	.id = MLXSW_REG_MTCAP_ID,
-	.len = MLXSW_REG_MTCAP_LEN,
-};
+MLXSW_REG_DEFINE(mtcap, MLXSW_REG_MTCAP_ID, MLXSW_REG_MTCAP_LEN);
 
 /* reg_mtcap_sensor_count
  * Number of sensors supported by the device.
@@ -4593,10 +4449,7 @@ MLXSW_ITEM32(reg, mtcap, sensor_count, 0x00, 0, 7);
 #define MLXSW_REG_MTMP_ID 0x900A
 #define MLXSW_REG_MTMP_LEN 0x20
 
-static const struct mlxsw_reg_info mlxsw_reg_mtmp = {
-	.id = MLXSW_REG_MTMP_ID,
-	.len = MLXSW_REG_MTMP_LEN,
-};
+MLXSW_REG_DEFINE(mtmp, MLXSW_REG_MTMP_ID, MLXSW_REG_MTMP_LEN);
 
 /* reg_mtmp_sensor_index
  * Sensors index to access.
@@ -4679,10 +4532,7 @@ static inline void mlxsw_reg_mtmp_unpack(char *payload, unsigned int *p_temp,
 #define MLXSW_REG_MPAT_ID 0x901A
 #define MLXSW_REG_MPAT_LEN 0x78
 
-static const struct mlxsw_reg_info mlxsw_reg_mpat = {
-	.id = MLXSW_REG_MPAT_ID,
-	.len = MLXSW_REG_MPAT_LEN,
-};
+MLXSW_REG_DEFINE(mpat, MLXSW_REG_MPAT_ID, MLXSW_REG_MPAT_LEN);
 
 /* reg_mpat_pa_id
  * Port Analyzer ID.
@@ -4742,10 +4592,7 @@ static inline void mlxsw_reg_mpat_pack(char *payload, u8 pa_id,
 #define MLXSW_REG_MPAR_ID 0x901B
 #define MLXSW_REG_MPAR_LEN 0x08
 
-static const struct mlxsw_reg_info mlxsw_reg_mpar = {
-	.id = MLXSW_REG_MPAR_ID,
-	.len = MLXSW_REG_MPAR_LEN,
-};
+MLXSW_REG_DEFINE(mpar, MLXSW_REG_MPAR_ID, MLXSW_REG_MPAR_LEN);
 
 /* reg_mpar_local_port
  * The local port to mirror the packets from.
@@ -4795,10 +4642,7 @@ static inline void mlxsw_reg_mpar_pack(char *payload, u8 local_port,
 #define MLXSW_REG_MLCR_ID 0x902B
 #define MLXSW_REG_MLCR_LEN 0x0C
 
-static const struct mlxsw_reg_info mlxsw_reg_mlcr = {
-	.id = MLXSW_REG_MLCR_ID,
-	.len = MLXSW_REG_MLCR_LEN,
-};
+MLXSW_REG_DEFINE(mlcr, MLXSW_REG_MLCR_ID, MLXSW_REG_MLCR_LEN);
 
 /* reg_mlcr_local_port
  * Local port number.
@@ -4839,10 +4683,7 @@ static inline void mlxsw_reg_mlcr_pack(char *payload, u8 local_port,
 #define MLXSW_REG_SBPR_ID 0xB001
 #define MLXSW_REG_SBPR_LEN 0x14
 
-static const struct mlxsw_reg_info mlxsw_reg_sbpr = {
-	.id = MLXSW_REG_SBPR_ID,
-	.len = MLXSW_REG_SBPR_LEN,
-};
+MLXSW_REG_DEFINE(sbpr, MLXSW_REG_SBPR_ID, MLXSW_REG_SBPR_LEN);
 
 /* shared direstion enum for SBPR, SBCM, SBPM */
 enum mlxsw_reg_sbxx_dir {
@@ -4899,10 +4740,7 @@ static inline void mlxsw_reg_sbpr_pack(char *payload, u8 pool,
 #define MLXSW_REG_SBCM_ID 0xB002
 #define MLXSW_REG_SBCM_LEN 0x28
 
-static const struct mlxsw_reg_info mlxsw_reg_sbcm = {
-	.id = MLXSW_REG_SBCM_ID,
-	.len = MLXSW_REG_SBCM_LEN,
-};
+MLXSW_REG_DEFINE(sbcm, MLXSW_REG_SBCM_ID, MLXSW_REG_SBCM_LEN);
 
 /* reg_sbcm_local_port
  * Local port number.
@@ -4979,10 +4817,7 @@ static inline void mlxsw_reg_sbcm_pack(char *payload, u8 local_port, u8 pg_buff,
 #define MLXSW_REG_SBPM_ID 0xB003
 #define MLXSW_REG_SBPM_LEN 0x28
 
-static const struct mlxsw_reg_info mlxsw_reg_sbpm = {
-	.id = MLXSW_REG_SBPM_ID,
-	.len = MLXSW_REG_SBPM_LEN,
-};
+MLXSW_REG_DEFINE(sbpm, MLXSW_REG_SBPM_ID, MLXSW_REG_SBPM_LEN);
 
 /* reg_sbpm_local_port
  * Local port number.
@@ -5073,10 +4908,7 @@ static inline void mlxsw_reg_sbpm_unpack(char *payload, u32 *p_buff_occupancy,
 #define MLXSW_REG_SBMM_ID 0xB004
 #define MLXSW_REG_SBMM_LEN 0x28
 
-static const struct mlxsw_reg_info mlxsw_reg_sbmm = {
-	.id = MLXSW_REG_SBMM_ID,
-	.len = MLXSW_REG_SBMM_LEN,
-};
+MLXSW_REG_DEFINE(sbmm, MLXSW_REG_SBMM_ID, MLXSW_REG_SBMM_LEN);
 
 /* reg_sbmm_prio
  * Switch Priority.
@@ -5135,10 +4967,7 @@ static inline void mlxsw_reg_sbmm_pack(char *payload, u8 prio, u32 min_buff,
 			    MLXSW_REG_SBSR_REC_LEN *	\
 			    MLXSW_REG_SBSR_REC_MAX_COUNT)
 
-static const struct mlxsw_reg_info mlxsw_reg_sbsr = {
-	.id = MLXSW_REG_SBSR_ID,
-	.len = MLXSW_REG_SBSR_LEN,
-};
+MLXSW_REG_DEFINE(sbsr, MLXSW_REG_SBSR_ID, MLXSW_REG_SBSR_LEN);
 
 /* reg_sbsr_clr
  * Clear Max Buffer Occupancy. When this bit is set, the max_buff_occupancy
@@ -5228,10 +5057,7 @@ static inline void mlxsw_reg_sbsr_rec_unpack(char *payload, int rec_index,
 #define MLXSW_REG_SBIB_ID 0xB006
 #define MLXSW_REG_SBIB_LEN 0x10
 
-static const struct mlxsw_reg_info mlxsw_reg_sbib = {
-	.id = MLXSW_REG_SBIB_ID,
-	.len = MLXSW_REG_SBIB_LEN,
-};
+MLXSW_REG_DEFINE(sbib, MLXSW_REG_SBIB_ID, MLXSW_REG_SBIB_LEN);
 
 /* reg_sbib_local_port
  * Local port number
-- 
2.5.5
