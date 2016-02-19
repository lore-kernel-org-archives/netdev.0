From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/16] i40e: Expose some registers to program parser, FD and RSS logic
Date: Fri, 19 Feb 2016 01:54:04 -0800
Message-ID: <1455875651-21696-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455875651-21696-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:35306 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1427414AbcBSJyW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Feb 2016 04:54:22 -0500
In-Reply-To: <1455875651-21696-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

This patch adds 7 new register definitions for programming the
parser, flow director and RSS blocks in the HW.

Change-ID: I31e76673125275f3c69a14c646361919d04dc987
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_register.h | 48 +++++++++++++++++++++++++
 1 file changed, 48 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_register.h b/drivers/net/ethernet/intel/i40e/i40e_register.h
index dc0402f..86ca27f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_register.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_register.h
@@ -2045,6 +2045,14 @@
 #define I40E_PRTPM_TLPIC 0x001E43C0 /* Reset: GLOBR */
 #define I40E_PRTPM_TLPIC_ETLPIC_SHIFT 0
 #define I40E_PRTPM_TLPIC_ETLPIC_MASK I40E_MASK(0xFFFFFFFF, I40E_PRTPM_TLPIC_ETLPIC_SHIFT)
+#define I40E_GL_PRS_FVBM(_i) (0x00269760 + ((_i) * 4)) /* _i=0...3 */ /* Reset: CORER */
+#define I40E_GL_PRS_FVBM_MAX_INDEX 3
+#define I40E_GL_PRS_FVBM_FV_BYTE_INDX_SHIFT 0
+#define I40E_GL_PRS_FVBM_FV_BYTE_INDX_MASK I40E_MASK(0x7F, I40E_GL_PRS_FVBM_FV_BYTE_INDX_SHIFT)
+#define I40E_GL_PRS_FVBM_RULE_BUS_INDX_SHIFT 8
+#define I40E_GL_PRS_FVBM_RULE_BUS_INDX_MASK I40E_MASK(0x3F, I40E_GL_PRS_FVBM_RULE_BUS_INDX_SHIFT)
+#define I40E_GL_PRS_FVBM_MSK_ENA_SHIFT 31
+#define I40E_GL_PRS_FVBM_MSK_ENA_MASK I40E_MASK(0x1, I40E_GL_PRS_FVBM_MSK_ENA_SHIFT)
 #define I40E_GLRPB_DPSS 0x000AC828 /* Reset: CORER */
 #define I40E_GLRPB_DPSS_DPS_TCN_SHIFT 0
 #define I40E_GLRPB_DPSS_DPS_TCN_MASK I40E_MASK(0xFFFFF, I40E_GLRPB_DPSS_DPS_TCN_SHIFT)
@@ -2216,6 +2224,14 @@
 #define I40E_PRTQF_FD_FLXINSET_MAX_INDEX 63
 #define I40E_PRTQF_FD_FLXINSET_INSET_SHIFT 0
 #define I40E_PRTQF_FD_FLXINSET_INSET_MASK I40E_MASK(0xFF, I40E_PRTQF_FD_FLXINSET_INSET_SHIFT)
+#define I40E_PRTQF_FD_INSET(_i, _j) (0x00250000 + ((_i) * 64 + (_j) * 32)) /* _i=0...63, _j=0...1 */ /* Reset: CORER */
+#define I40E_PRTQF_FD_INSET_MAX_INDEX 63
+#define I40E_PRTQF_FD_INSET_INSET_SHIFT 0
+#define I40E_PRTQF_FD_INSET_INSET_MASK I40E_MASK(0xFFFFFFFF, I40E_PRTQF_FD_INSET_INSET_SHIFT)
+#define I40E_PRTQF_FD_INSET(_i, _j) (0x00250000 + ((_i) * 64 + (_j) * 32)) /* _i=0...63, _j=0...1 */ /* Reset: CORER */
+#define I40E_PRTQF_FD_INSET_MAX_INDEX 63
+#define I40E_PRTQF_FD_INSET_INSET_SHIFT 0
+#define I40E_PRTQF_FD_INSET_INSET_MASK I40E_MASK(0xFFFFFFFF, I40E_PRTQF_FD_INSET_INSET_SHIFT)
 #define I40E_PRTQF_FD_MSK(_i, _j) (0x00252000 + ((_i) * 64 + (_j) * 32)) /* _i=0...63, _j=0...1 */ /* Reset: CORER */
 #define I40E_PRTQF_FD_MSK_MAX_INDEX 63
 #define I40E_PRTQF_FD_MSK_MASK_SHIFT 0
@@ -5155,6 +5171,38 @@
 #define I40E_GLQF_FD_PCTYPES_MAX_INDEX 63
 #define I40E_GLQF_FD_PCTYPES_FD_PCTYPE_SHIFT 0
 #define I40E_GLQF_FD_PCTYPES_FD_PCTYPE_MASK I40E_MASK(0x3F, I40E_GLQF_FD_PCTYPES_FD_PCTYPE_SHIFT)
+#define I40E_GLQF_FD_MSK(_i, _j) (0x00267200 + ((_i) * 4 + (_j) * 8)) /* _i=0...1, _j=0...63 */ /* Reset: CORER */
+#define I40E_GLQF_FD_MSK_MAX_INDEX 1
+#define I40E_GLQF_FD_MSK_MASK_SHIFT 0
+#define I40E_GLQF_FD_MSK_MASK_MASK I40E_MASK(0xFFFF, I40E_GLQF_FD_MSK_MASK_SHIFT)
+#define I40E_GLQF_FD_MSK_OFFSET_SHIFT 16
+#define I40E_GLQF_FD_MSK_OFFSET_MASK I40E_MASK(0x3F, I40E_GLQF_FD_MSK_OFFSET_SHIFT)
+#define I40E_GLQF_HASH_INSET(_i, _j) (0x00267600 + ((_i) * 4 + (_j) * 8)) /* _i=0...1, _j=0...63 */ /* Reset: CORER */
+#define I40E_GLQF_HASH_INSET_MAX_INDEX 1
+#define I40E_GLQF_HASH_INSET_INSET_SHIFT 0
+#define I40E_GLQF_HASH_INSET_INSET_MASK I40E_MASK(0xFFFFFFFF, I40E_GLQF_HASH_INSET_INSET_SHIFT)
+#define I40E_GLQF_HASH_MSK(_i, _j) (0x00267A00 + ((_i) * 4 + (_j) * 8)) /* _i=0...1, _j=0...63 */ /* Reset: CORER */
+#define I40E_GLQF_HASH_MSK_MAX_INDEX 1
+#define I40E_GLQF_HASH_MSK_MASK_SHIFT 0
+#define I40E_GLQF_HASH_MSK_MASK_MASK I40E_MASK(0xFFFF, I40E_GLQF_HASH_MSK_MASK_SHIFT)
+#define I40E_GLQF_HASH_MSK_OFFSET_SHIFT 16
+#define I40E_GLQF_HASH_MSK_OFFSET_MASK I40E_MASK(0x3F, I40E_GLQF_HASH_MSK_OFFSET_SHIFT)
+#define I40E_GLQF_ORT(_i) (0x00268900 + ((_i) * 4)) /* _i=0...63 */ /* Reset: CORER */
+#define I40E_GLQF_ORT_MAX_INDEX 63
+#define I40E_GLQF_ORT_PIT_INDX_SHIFT 0
+#define I40E_GLQF_ORT_PIT_INDX_MASK I40E_MASK(0x1F, I40E_GLQF_ORT_PIT_INDX_SHIFT)
+#define I40E_GLQF_ORT_FIELD_CNT_SHIFT 5
+#define I40E_GLQF_ORT_FIELD_CNT_MASK I40E_MASK(0x3, I40E_GLQF_ORT_FIELD_CNT_SHIFT)
+#define I40E_GLQF_ORT_FLX_PAYLOAD_SHIFT 7
+#define I40E_GLQF_ORT_FLX_PAYLOAD_MASK I40E_MASK(0x1, I40E_GLQF_ORT_FLX_PAYLOAD_SHIFT)
+#define I40E_GLQF_PIT(_i) (0x00268C80 + ((_i) * 4)) /* _i=0...23 */ /* Reset: CORER */
+#define I40E_GLQF_PIT_MAX_INDEX 23
+#define I40E_GLQF_PIT_SOURCE_OFF_SHIFT 0
+#define I40E_GLQF_PIT_SOURCE_OFF_MASK I40E_MASK(0x1F, I40E_GLQF_PIT_SOURCE_OFF_SHIFT)
+#define I40E_GLQF_PIT_FSIZE_SHIFT 5
+#define I40E_GLQF_PIT_FSIZE_MASK I40E_MASK(0x1F, I40E_GLQF_PIT_FSIZE_SHIFT)
+#define I40E_GLQF_PIT_DEST_OFF_SHIFT 10
+#define I40E_GLQF_PIT_DEST_OFF_MASK I40E_MASK(0x3F, I40E_GLQF_PIT_DEST_OFF_SHIFT)
 #define I40E_GLQF_FDEVICTENA(_i) (0x00270384 + ((_i) * 4)) /* _i=0...1 */ /* Reset: CORER */
 #define I40E_GLQF_FDEVICTENA_MAX_INDEX 1
 #define I40E_GLQF_FDEVICTENA_GLQF_FDEVICTENA_SHIFT 0
-- 
2.5.0
