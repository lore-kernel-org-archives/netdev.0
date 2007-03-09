From: Linsys Contractor Mithlesh Thukral <mithlesh@netxen.com>
Subject: [PATCH 5/5] NetXen: Fix the setup of resources for hardware on multi port cards
Date: Fri, 9 Mar 2007 00:12:28 -0800
Message-ID: <200703090812.l298CS1c011855@dut39.unminc.com>
Cc: amitkale@netxen.com, jeff@garzik.org, mithlesh@netxen.com,
	netxenproj@linsyssoft.com, rob@netxen.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:12997 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752048AbXCIIM2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2007 03:12:28 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NetXen: Fix the setup of resources for hardware on multi port cards.

Signed-off-by: Mithlesh Thukral <mithlesh@netxen.com>
---

 drivers/net/netxen/netxen_nic_hw.c       |    8 +++++---
 drivers/net/netxen/netxen_nic_phan_reg.h |    6 +++---
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 81ebc81..4ce33d8 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -294,6 +294,7 @@ int netxen_nic_hw_resources(struct netxe
 	u32 card_cmdring = 0;
 	struct netxen_recv_context *recv_ctx;
 	struct netxen_rcv_desc_ctx *rcv_desc;
+	int func_id = adapter->portnum;
 
 	DPRINTK(INFO, "crb_base: %lx %x", NETXEN_PCI_CRBSPACE,
 		PCI_OFFSET_SECOND_RANGE(adapter, NETXEN_PCI_CRBSPACE));
@@ -349,6 +350,7 @@ int netxen_nic_hw_resources(struct netxe
 	}
 	memset(addr, 0, sizeof(struct netxen_ring_ctx));
 	adapter->ctx_desc = (struct netxen_ring_ctx *)addr;
+	adapter->ctx_desc->ctx_id = adapter->portnum;
 	adapter->ctx_desc->cmd_consumer_offset =
 	    cpu_to_le64(adapter->ctx_desc_phys_addr +
 			sizeof(struct netxen_ring_ctx));
@@ -418,11 +420,11 @@ int netxen_nic_hw_resources(struct netxe
 	/* Window = 1 */
 
 	writel(lower32(adapter->ctx_desc_phys_addr),
-	       NETXEN_CRB_NORMALIZE(adapter, CRB_CTX_ADDR_REG_LO));
+	       NETXEN_CRB_NORMALIZE(adapter, CRB_CTX_ADDR_REG_LO(func_id)));
 	writel(upper32(adapter->ctx_desc_phys_addr),
-	       NETXEN_CRB_NORMALIZE(adapter, CRB_CTX_ADDR_REG_HI));
+	       NETXEN_CRB_NORMALIZE(adapter, CRB_CTX_ADDR_REG_HI(func_id)));
 	writel(NETXEN_CTX_SIGNATURE,
-	       NETXEN_CRB_NORMALIZE(adapter, CRB_CTX_SIGNATURE_REG));
+	       NETXEN_CRB_NORMALIZE(adapter, CRB_CTX_SIGNATURE_REG(func_id)));
 	return err;
 }
 
diff --git a/drivers/net/netxen/netxen_nic_phan_reg.h b/drivers/net/netxen/netxen_nic_phan_reg.h
index f7eb627..97e34e6 100644
--- a/drivers/net/netxen/netxen_nic_phan_reg.h
+++ b/drivers/net/netxen/netxen_nic_phan_reg.h
@@ -151,9 +151,9 @@ #else
 extern struct netxen_recv_crb recv_crb_registers[];
 extern u64 ctx_addr_sig_regs[][3];
 #endif				/* DEFINE_GLOBAL_RECEIVE_CRB */
-#define CRB_CTX_ADDR_REG_LO            (ctx_addr_sig_regs[0][0])
-#define CRB_CTX_ADDR_REG_HI            (ctx_addr_sig_regs[0][2])
-#define CRB_CTX_SIGNATURE_REG       (ctx_addr_sig_regs[0][1])
+#define CRB_CTX_ADDR_REG_LO(FUNC_ID)	(ctx_addr_sig_regs[FUNC_ID][0])
+#define CRB_CTX_ADDR_REG_HI(FUNC_ID)	(ctx_addr_sig_regs[FUNC_ID][2])
+#define CRB_CTX_SIGNATURE_REG(FUNC_ID)	(ctx_addr_sig_regs[FUNC_ID][1])
 
 /*
  * Temperature control.
