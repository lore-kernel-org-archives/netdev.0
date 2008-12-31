From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: [PATCH] net/ehea: use consistent type
Date: Wed, 31 Dec 2008 14:17:30 +1100
Message-ID: <20081231141730.81449124.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ppc-dev <linuxppc-dev@ozlabs.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:38383 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751994AbYLaDRd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Dec 2008 22:17:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ehea_plpar_hcall9() takes an unsigned long array, so pass that.

This change will avoid some warnings when we change u64 to unsigned
long long.

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/ehea/ehea_phyp.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ehea/ehea_phyp.c b/drivers/net/ehea/ehea_phyp.c
index 2a33a61..8fe9dca 100644
--- a/drivers/net/ehea/ehea_phyp.c
+++ b/drivers/net/ehea/ehea_phyp.c
@@ -214,7 +214,7 @@ u64 ehea_h_alloc_resource_qp(const u64 adapter_handle,
 			     u64 *qp_handle, struct h_epas *h_epas)
 {
 	u64 hret;
-	u64 outs[PLPAR_HCALL9_BUFSIZE];
+	unsigned long outs[PLPAR_HCALL9_BUFSIZE];
 
 	u64 allocate_controls =
 	    EHEA_BMASK_SET(H_ALL_RES_QP_EQPO, init_attr->low_lat_rq1 ? 1 : 0)
@@ -312,7 +312,7 @@ u64 ehea_h_alloc_resource_cq(const u64 adapter_handle,
 			     u64 *cq_handle, struct h_epas *epas)
 {
 	u64 hret;
-	u64 outs[PLPAR_HCALL9_BUFSIZE];
+	unsigned long outs[PLPAR_HCALL9_BUFSIZE];
 
 	hret = ehea_plpar_hcall9(H_ALLOC_HEA_RESOURCE,
 				 outs,
@@ -374,7 +374,7 @@ u64 ehea_h_alloc_resource_eq(const u64 adapter_handle,
 			     struct ehea_eq_attr *eq_attr, u64 *eq_handle)
 {
 	u64 hret, allocate_controls;
-	u64 outs[PLPAR_HCALL9_BUFSIZE];
+	unsigned long outs[PLPAR_HCALL9_BUFSIZE];
 
 	/* resource type */
 	allocate_controls =
@@ -407,7 +407,7 @@ u64 ehea_h_modify_ehea_qp(const u64 adapter_handle, const u8 cat,
 			  u16 *out_swr, u16 *out_rwr)
 {
 	u64 hret;
-	u64 outs[PLPAR_HCALL9_BUFSIZE];
+	unsigned long outs[PLPAR_HCALL9_BUFSIZE];
 
 	hret = ehea_plpar_hcall9(H_MODIFY_HEA_QP,
 				 outs,
@@ -449,7 +449,7 @@ u64 ehea_h_register_smr(const u64 adapter_handle, const u64 orig_mr_handle,
 			struct ehea_mr *mr)
 {
 	u64 hret;
-	u64 outs[PLPAR_HCALL9_BUFSIZE];
+	unsigned long outs[PLPAR_HCALL9_BUFSIZE];
 
 	hret = ehea_plpar_hcall9(H_REGISTER_SMR,
 				 outs,
@@ -468,7 +468,7 @@ u64 ehea_h_register_smr(const u64 adapter_handle, const u64 orig_mr_handle,
 
 u64 ehea_h_disable_and_get_hea(const u64 adapter_handle, const u64 qp_handle)
 {
-	u64 outs[PLPAR_HCALL9_BUFSIZE];
+	unsigned long outs[PLPAR_HCALL9_BUFSIZE];
 
 	return ehea_plpar_hcall9(H_DISABLE_AND_GET_HEA,
 				 outs,
@@ -493,7 +493,7 @@ u64 ehea_h_alloc_resource_mr(const u64 adapter_handle, const u64 vaddr,
 			     const u32 pd, u64 *mr_handle, u32 *lkey)
 {
 	u64 hret;
-	u64 outs[PLPAR_HCALL9_BUFSIZE];
+	unsigned long outs[PLPAR_HCALL9_BUFSIZE];
 
 	hret = ehea_plpar_hcall9(H_ALLOC_HEA_RESOURCE,
 				 outs,
@@ -564,7 +564,7 @@ u64 ehea_h_modify_ehea_port(const u64 adapter_handle, const u16 port_num,
 			    const u8 cb_cat, const u64 select_mask,
 			    void *cb_addr)
 {
-	u64 outs[PLPAR_HCALL9_BUFSIZE];
+	unsigned long outs[PLPAR_HCALL9_BUFSIZE];
 	u64 port_info;
 	u64 arr_index = 0;
 	u64 cb_logaddr = virt_to_abs(cb_addr);
-- 
1.6.0.5

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/
