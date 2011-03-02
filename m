From: dykmanj@linux.vnet.ibm.com
Subject: [PATCH 20/27] HFI: Close window hypervisor call
Date: Wed,  2 Mar 2011 16:10:06 -0500
Message-ID: <1299100213-8770-20-git-send-email-dykmanj@linux.vnet.ibm.com>
References: <1299100213-8770-1-git-send-email-dykmanj@linux.vnet.ibm.com>
Cc: Jim Dykman <dykmanj@linux.vnet.ibm.com>,
	Piyush Chaudhary <piyushc@linux.vnet.ibm.com>,
	Fu-Chung Chang <fcchang@linux.vnet.ibm.com>,
	" William S. Cadden" <wscadden@linux.vnet.ibm.com>,
	" Wen C. Chen" <winstonc@linux.vnet.ibm.com>,
	Scot Sakolish <sakolish@linux.vnet.ibm.com>,
	Jian Xiao <jian@linux.vnet.ibm.com>,
	" Carol L. Soto" <clsoto@linux.vnet.ibm.com>,
	" Sarah J. Sheppard" <sjsheppa@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:52680 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757570Ab1CBVKa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2011 16:10:30 -0500
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e2.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p22KqAfX003781
	for <netdev@vger.kernel.org>; Wed, 2 Mar 2011 15:52:12 -0500
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 3D9426E803F
	for <netdev@vger.kernel.org>; Wed,  2 Mar 2011 16:10:29 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p22LAS512277628
	for <netdev@vger.kernel.org>; Wed, 2 Mar 2011 16:10:28 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p22LAR55032348
	for <netdev@vger.kernel.org>; Wed, 2 Mar 2011 16:10:28 -0500
To: netdev@vger.kernel.org
In-Reply-To: <1299100213-8770-1-git-send-email-dykmanj@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jim Dykman <dykmanj@linux.vnet.ibm.com>

Signed-off-by:  Piyush Chaudhary <piyushc@linux.vnet.ibm.com>
Signed-off-by:  Jim Dykman <dykmanj@linux.vnet.ibm.com>
Signed-off-by:  Fu-Chung Chang <fcchang@linux.vnet.ibm.com>
Signed-off-by:  William S. Cadden <wscadden@linux.vnet.ibm.com>
Signed-off-by:  Wen C. Chen <winstonc@linux.vnet.ibm.com>
Signed-off-by:  Scot Sakolish <sakolish@linux.vnet.ibm.com>
Signed-off-by:  Jian Xiao <jian@linux.vnet.ibm.com>
Signed-off-by:  Carol L. Soto <clsoto@linux.vnet.ibm.com>
Signed-off-by:  Sarah J. Sheppard <sjsheppa@linux.vnet.ibm.com>
---
 drivers/net/hfi/core/hfidd_hcalls.c |   22 ++++++++++++++
 drivers/net/hfi/core/hfidd_proto.h  |    1 +
 drivers/net/hfi/core/hfidd_window.c |   53 +++++++++++++++++++++++++++++++++--
 3 files changed, 73 insertions(+), 3 deletions(-)

diff --git a/drivers/net/hfi/core/hfidd_hcalls.c b/drivers/net/hfi/core/hfidd_hcalls.c
index 1915336..4bc6525 100644
--- a/drivers/net/hfi/core/hfidd_hcalls.c
+++ b/drivers/net/hfi/core/hfidd_hcalls.c
@@ -153,6 +153,17 @@ static inline long long h_hfi_open_window(int token,
 	return rc;
 }
 
+static inline long long h_hfi_close_window(int token,
+		u64 HFI_chip_ID,
+		u64 win_num,
+		u64 flag)
+{
+	return plpar_hcall_norets(token,
+		HFI_chip_ID,
+		win_num,
+		flag);
+}
+
 long long hfi_start_nmmu(u64 chip_id, void *nmmu_info)
 {
 	return h_nmmu_start(H_NMMU_START, chip_id, nmmu_info);
@@ -249,6 +260,17 @@ long long hfi_modify_mr(u64 chip_id, u64 request, u64 mr_handle,
 	return hvrc;
 }
 
+long long hfi_close_window(u64 unit_id, u64 win_id, u64 flag)
+{
+	long long hvrc;
+
+	hvrc = h_hfi_close_window(H_HFI_CLOSE_WINDOW,
+			unit_id,
+			win_id,
+			flag);
+			return hvrc;
+}
+
 long long hfi_free_mr(u64 chip_id, u64 res, u64 mr_handle, u64 sub_region_id)
 {
 	long long	hvrc;
diff --git a/drivers/net/hfi/core/hfidd_proto.h b/drivers/net/hfi/core/hfidd_proto.h
index e065d56..f531dcd 100644
--- a/drivers/net/hfi/core/hfidd_proto.h
+++ b/drivers/net/hfi/core/hfidd_proto.h
@@ -94,6 +94,7 @@ long long hfi_modify_mr(u64 chip_id, u64 request, u64 mr_handle,
 		u64 e_addr,
 		u64 l_addr,
 		u64 num_pg_sz);
+long long hfi_close_window(u64 unit_id, u64 win_id, u64 flag);
 long long hfi_free_mr(u64 chip_id, u64 res, u64 mr_handle,
 		u64 sub_region_id);
 long long hfi_hquery_interface(u64 unit_id, u64 subtype, u64 query_p,
diff --git a/drivers/net/hfi/core/hfidd_window.c b/drivers/net/hfi/core/hfidd_window.c
index 1724c30..ff8b9f0 100644
--- a/drivers/net/hfi/core/hfidd_window.c
+++ b/drivers/net/hfi/core/hfidd_window.c
@@ -460,6 +460,43 @@ static int hfi_hcall_to_open_window(struct hfidd_acs *p_acs,
 	return 0;
 }
 
+/* Call to CLOSE WINDOW hcall */
+static int hfi_hcall_to_close_window(struct hfidd_acs *p_acs,
+		struct hfidd_window *win_p)
+{
+	int	rc = 0;
+	long long hvrc = 0;
+	u64	start_time = get_jiffies_64();
+
+	hvrc = hfi_close_window(p_acs->dds.hfi_id,
+			win_p->index,
+			H_CLOSE);
+
+	/*
+	 * Need to call CLOSE WINDOW with flag H_CHECK_CLOSED
+	 * to check when the window is completely closed
+	 */
+	while (hvrc == H_BUSY) {
+		hvrc = hfi_close_window(p_acs->dds.hfi_id,
+				win_p->index,
+				H_CHECK_CLOSED);
+		if (hvrc != H_BUSY)
+			break;
+		if (hfidd_age_hcall(start_time))
+			break;
+	}
+
+	if (hvrc != H_SUCCESS) {
+		win_p->state = WIN_FAIL_CLOSE;
+		rc = -EIO;
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfi_hcall_to_close_window: CLOSE WINDOW failed, "
+			"hvrc=0x%llx\n", hvrc);
+	}
+
+	return rc;
+}
+
 /*
  * Map the Effective Address pages for Memory Regions.
  * If more than one page, need to setup a page containing
@@ -1006,7 +1043,7 @@ int hfidd_open_window_func(struct hfidd_acs *p_acs, unsigned int is_userspace,
 		dev_printk(KERN_ERR, p_acs->hfidd_dev,
 			"hfidd_open_window_func: hfi_map_mmio_regs "
 			"failed, rc = 0x%x\n", rc);
-		goto hfidd_open_window_func_err4;
+		goto hfidd_open_window_func_err5;
 	}
 
 	/* tell user the local ISR id */
@@ -1020,7 +1057,7 @@ int hfidd_open_window_func(struct hfidd_acs *p_acs, unsigned int is_userspace,
 		dev_printk(KERN_ERR, p_acs->hfidd_dev,
 			"hfidd_open_window_func: hfi_copy_to_user "
 			"failed, rc = 0x%x\n", rc);
-		goto hfidd_open_window_func_err5;
+		goto hfidd_open_window_func_err6;
 	}
 
 	spin_lock(&(win_p->win_lock));
@@ -1032,9 +1069,11 @@ int hfidd_open_window_func(struct hfidd_acs *p_acs, unsigned int is_userspace,
 	kfree(local_p);
 	return rc;
 
-hfidd_open_window_func_err5:
+hfidd_open_window_func_err6:
 	if (is_userspace)
 		hfidd_unmap(local_p->mmio_regs.use.kptr, PAGE_SIZE_64K);
+hfidd_open_window_func_err5:
+	hfi_hcall_to_close_window(p_acs, win_p);
 hfidd_open_window_func_err4:
 	hfi_destroy_window_parm(p_acs, is_userspace, win_p, local_p);
 hfidd_open_window_func_err3:
@@ -1104,6 +1143,14 @@ int hfidd_close_window_internal(struct hfidd_acs *p_acs,
 		goto hfidd_close_window_internal_err0;
 	}
 
+	rc = hfi_hcall_to_close_window(p_acs, win_p);
+	if (rc) {
+		dev_printk(KERN_ERR, p_acs->hfidd_dev,
+			"hfidd_close_window_internal: hfi_hcall_to_close_window "
+			"failed, rc = 0x%x\n", rc);
+		goto hfidd_close_window_internal_err0;
+	}
+
 	hfi_destroy_window_info(p_acs, win_p);
 
 	/* Call hcall to unregister MR in the MMU */
-- 
1.7.3.1

