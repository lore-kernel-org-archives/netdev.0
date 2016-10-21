From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 4/6] mlxsw: reg: Generare register names automatically
Date: Fri, 21 Oct 2016 16:07:21 +0200
Message-ID: <1477058843-9981-5-git-send-email-jiri@resnulli.us>
References: <1477058843-9981-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:34067 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755689AbcJUOHd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 10:07:33 -0400
Received: by mail-lf0-f65.google.com with SMTP id x23so5851645lfi.1
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 07:07:33 -0700 (PDT)
In-Reply-To: <1477058843-9981-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Extend the MLXSW_REG_DEFINE macro to store register name in string form.
Use this string later on instead of hard coded string values.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Acked-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 196 +++++++++++-------------------
 1 file changed, 73 insertions(+), 123 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 770dbb8..debcf26 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -48,12 +48,14 @@
 struct mlxsw_reg_info {
 	u16 id;
 	u16 len; /* In u8 */
+	const char *name;
 };
 
 #define MLXSW_REG_DEFINE(_name, _id, _len)				\
 static const struct mlxsw_reg_info mlxsw_reg_##_name = {		\
 	.id = _id,							\
 	.len = _len,							\
+	.name = #_name,							\
 }
 
 #define MLXSW_REG(type) (&mlxsw_reg_##type)
@@ -5082,132 +5084,80 @@ static inline void mlxsw_reg_sbib_pack(char *payload, u8 local_port,
 	mlxsw_reg_sbib_buff_size_set(payload, buff_size);
 }
 
+static const struct mlxsw_reg_info *mlxsw_reg_infos[] = {
+	MLXSW_REG(sgcr),
+	MLXSW_REG(spad),
+	MLXSW_REG(smid),
+	MLXSW_REG(sspr),
+	MLXSW_REG(sfdat),
+	MLXSW_REG(sfd),
+	MLXSW_REG(sfn),
+	MLXSW_REG(spms),
+	MLXSW_REG(spvid),
+	MLXSW_REG(spvm),
+	MLXSW_REG(spaft),
+	MLXSW_REG(sfgc),
+	MLXSW_REG(sftr),
+	MLXSW_REG(sfdf),
+	MLXSW_REG(sldr),
+	MLXSW_REG(slcr),
+	MLXSW_REG(slcor),
+	MLXSW_REG(spmlr),
+	MLXSW_REG(svfa),
+	MLXSW_REG(svpe),
+	MLXSW_REG(sfmr),
+	MLXSW_REG(spvmlr),
+	MLXSW_REG(qtct),
+	MLXSW_REG(qeec),
+	MLXSW_REG(pmlp),
+	MLXSW_REG(pmtu),
+	MLXSW_REG(ptys),
+	MLXSW_REG(ppad),
+	MLXSW_REG(paos),
+	MLXSW_REG(pfcc),
+	MLXSW_REG(ppcnt),
+	MLXSW_REG(pptb),
+	MLXSW_REG(pbmc),
+	MLXSW_REG(pspa),
+	MLXSW_REG(htgt),
+	MLXSW_REG(hpkt),
+	MLXSW_REG(rgcr),
+	MLXSW_REG(ritr),
+	MLXSW_REG(ratr),
+	MLXSW_REG(ralta),
+	MLXSW_REG(ralst),
+	MLXSW_REG(raltb),
+	MLXSW_REG(ralue),
+	MLXSW_REG(rauht),
+	MLXSW_REG(raleu),
+	MLXSW_REG(rauhtd),
+	MLXSW_REG(mfcr),
+	MLXSW_REG(mfsc),
+	MLXSW_REG(mfsm),
+	MLXSW_REG(mtcap),
+	MLXSW_REG(mtmp),
+	MLXSW_REG(mpat),
+	MLXSW_REG(mpar),
+	MLXSW_REG(mlcr),
+	MLXSW_REG(sbpr),
+	MLXSW_REG(sbcm),
+	MLXSW_REG(sbpm),
+	MLXSW_REG(sbmm),
+	MLXSW_REG(sbsr),
+	MLXSW_REG(sbib),
+};
+
 static inline const char *mlxsw_reg_id_str(u16 reg_id)
 {
-	switch (reg_id) {
-	case MLXSW_REG_SGCR_ID:
-		return "SGCR";
-	case MLXSW_REG_SPAD_ID:
-		return "SPAD";
-	case MLXSW_REG_SMID_ID:
-		return "SMID";
-	case MLXSW_REG_SSPR_ID:
-		return "SSPR";
-	case MLXSW_REG_SFDAT_ID:
-		return "SFDAT";
-	case MLXSW_REG_SFD_ID:
-		return "SFD";
-	case MLXSW_REG_SFN_ID:
-		return "SFN";
-	case MLXSW_REG_SPMS_ID:
-		return "SPMS";
-	case MLXSW_REG_SPVID_ID:
-		return "SPVID";
-	case MLXSW_REG_SPVM_ID:
-		return "SPVM";
-	case MLXSW_REG_SPAFT_ID:
-		return "SPAFT";
-	case MLXSW_REG_SFGC_ID:
-		return "SFGC";
-	case MLXSW_REG_SFTR_ID:
-		return "SFTR";
-	case MLXSW_REG_SFDF_ID:
-		return "SFDF";
-	case MLXSW_REG_SLDR_ID:
-		return "SLDR";
-	case MLXSW_REG_SLCR_ID:
-		return "SLCR";
-	case MLXSW_REG_SLCOR_ID:
-		return "SLCOR";
-	case MLXSW_REG_SPMLR_ID:
-		return "SPMLR";
-	case MLXSW_REG_SVFA_ID:
-		return "SVFA";
-	case MLXSW_REG_SVPE_ID:
-		return "SVPE";
-	case MLXSW_REG_SFMR_ID:
-		return "SFMR";
-	case MLXSW_REG_SPVMLR_ID:
-		return "SPVMLR";
-	case MLXSW_REG_QTCT_ID:
-		return "QTCT";
-	case MLXSW_REG_QEEC_ID:
-		return "QEEC";
-	case MLXSW_REG_PMLP_ID:
-		return "PMLP";
-	case MLXSW_REG_PMTU_ID:
-		return "PMTU";
-	case MLXSW_REG_PTYS_ID:
-		return "PTYS";
-	case MLXSW_REG_PPAD_ID:
-		return "PPAD";
-	case MLXSW_REG_PAOS_ID:
-		return "PAOS";
-	case MLXSW_REG_PFCC_ID:
-		return "PFCC";
-	case MLXSW_REG_PPCNT_ID:
-		return "PPCNT";
-	case MLXSW_REG_PPTB_ID:
-		return "PPTB";
-	case MLXSW_REG_PBMC_ID:
-		return "PBMC";
-	case MLXSW_REG_PSPA_ID:
-		return "PSPA";
-	case MLXSW_REG_HTGT_ID:
-		return "HTGT";
-	case MLXSW_REG_HPKT_ID:
-		return "HPKT";
-	case MLXSW_REG_RGCR_ID:
-		return "RGCR";
-	case MLXSW_REG_RITR_ID:
-		return "RITR";
-	case MLXSW_REG_RATR_ID:
-		return "RATR";
-	case MLXSW_REG_RALTA_ID:
-		return "RALTA";
-	case MLXSW_REG_RALST_ID:
-		return "RALST";
-	case MLXSW_REG_RALTB_ID:
-		return "RALTB";
-	case MLXSW_REG_RALUE_ID:
-		return "RALUE";
-	case MLXSW_REG_RAUHT_ID:
-		return "RAUHT";
-	case MLXSW_REG_RALEU_ID:
-		return "RALEU";
-	case MLXSW_REG_RAUHTD_ID:
-		return "RAUHTD";
-	case MLXSW_REG_MFCR_ID:
-		return "MFCR";
-	case MLXSW_REG_MFSC_ID:
-		return "MFSC";
-	case MLXSW_REG_MFSM_ID:
-		return "MFSM";
-	case MLXSW_REG_MTCAP_ID:
-		return "MTCAP";
-	case MLXSW_REG_MPAT_ID:
-		return "MPAT";
-	case MLXSW_REG_MPAR_ID:
-		return "MPAR";
-	case MLXSW_REG_MTMP_ID:
-		return "MTMP";
-	case MLXSW_REG_MLCR_ID:
-		return "MLCR";
-	case MLXSW_REG_SBPR_ID:
-		return "SBPR";
-	case MLXSW_REG_SBCM_ID:
-		return "SBCM";
-	case MLXSW_REG_SBPM_ID:
-		return "SBPM";
-	case MLXSW_REG_SBMM_ID:
-		return "SBMM";
-	case MLXSW_REG_SBSR_ID:
-		return "SBSR";
-	case MLXSW_REG_SBIB_ID:
-		return "SBIB";
-	default:
-		return "*UNKNOWN*";
+	const struct mlxsw_reg_info *reg_info;
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(mlxsw_reg_infos); i++) {
+		reg_info = mlxsw_reg_infos[i];
+		if (reg_info->id == reg_id)
+			return reg_info->name;
 	}
+	return "*UNKNOWN*";
 }
 
 /* PUDE - Port Up / Down Event
-- 
2.5.5
