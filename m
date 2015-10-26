From: Robert Dolca <robert.dolca@intel.com>
Subject: [PATCH] nfc: nci: non-static functions can not be inline
Date: Mon, 26 Oct 2015 13:58:54 +0200
Message-ID: <1445860734-17651-1-git-send-email-robert.dolca@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org,
	Christophe Ricard <christophe.ricard@gmail.com>,
	Robert Dolca <robert.dolca@intel.com>
To: linux-nfc@lists.01.org,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>,
	Robert Dolca <robert.dolca@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:5455 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753485AbbJZL6v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Oct 2015 07:58:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Robert Dolca <robert.dolca@intel.com>
---
 include/net/nfc/nci_core.h |  8 ++++----
 net/nfc/nci/core.c         | 16 ++++++++--------
 2 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/include/net/nfc/nci_core.h b/include/net/nfc/nci_core.h
index 530df66..1e3db2b 100644
--- a/include/net/nfc/nci_core.h
+++ b/include/net/nfc/nci_core.h
@@ -351,13 +351,13 @@ static inline int nci_set_vendor_cmds(struct nci_dev *ndev,
 
 void nci_rsp_packet(struct nci_dev *ndev, struct sk_buff *skb);
 void nci_ntf_packet(struct nci_dev *ndev, struct sk_buff *skb);
-inline int nci_prop_rsp_packet(struct nci_dev *ndev, __u16 opcode,
+int nci_prop_rsp_packet(struct nci_dev *ndev, __u16 opcode,
 			struct sk_buff *skb);
-inline int nci_prop_ntf_packet(struct nci_dev *ndev, __u16 opcode,
+int nci_prop_ntf_packet(struct nci_dev *ndev, __u16 opcode,
 			struct sk_buff *skb);
-inline int nci_core_rsp_packet(struct nci_dev *ndev, __u16 opcode,
+int nci_core_rsp_packet(struct nci_dev *ndev, __u16 opcode,
 			struct sk_buff *skb);
-inline int nci_core_ntf_packet(struct nci_dev *ndev, __u16 opcode,
+int nci_core_ntf_packet(struct nci_dev *ndev, __u16 opcode,
 			struct sk_buff *skb);
 void nci_rx_data_packet(struct nci_dev *ndev, struct sk_buff *skb);
 int nci_send_cmd(struct nci_dev *ndev, __u16 opcode, __u8 plen, void *payload);
diff --git a/net/nfc/nci/core.c b/net/nfc/nci/core.c
index ecf420d..0767cc1 100644
--- a/net/nfc/nci/core.c
+++ b/net/nfc/nci/core.c
@@ -1314,29 +1314,29 @@ static int nci_op_ntf_packet(struct nci_dev *ndev, __u16 ntf_opcode,
 	return op->ntf(ndev, skb);
 }
 
-inline int nci_prop_rsp_packet(struct nci_dev *ndev, __u16 opcode,
-			       struct sk_buff *skb)
+int nci_prop_rsp_packet(struct nci_dev *ndev, __u16 opcode,
+			struct sk_buff *skb)
 {
 	return nci_op_rsp_packet(ndev, opcode, skb, ndev->ops->prop_ops,
 				 ndev->ops->n_prop_ops);
 }
 
-inline int nci_prop_ntf_packet(struct nci_dev *ndev, __u16 opcode,
-			       struct sk_buff *skb)
+int nci_prop_ntf_packet(struct nci_dev *ndev, __u16 opcode,
+			struct sk_buff *skb)
 {
 	return nci_op_ntf_packet(ndev, opcode, skb, ndev->ops->prop_ops,
 				 ndev->ops->n_prop_ops);
 }
 
-inline int nci_core_rsp_packet(struct nci_dev *ndev, __u16 opcode,
-			       struct sk_buff *skb)
+int nci_core_rsp_packet(struct nci_dev *ndev, __u16 opcode,
+			struct sk_buff *skb)
 {
 	return nci_op_rsp_packet(ndev, opcode, skb, ndev->ops->core_ops,
 				  ndev->ops->n_core_ops);
 }
 
-inline int nci_core_ntf_packet(struct nci_dev *ndev, __u16 opcode,
-			       struct sk_buff *skb)
+int nci_core_ntf_packet(struct nci_dev *ndev, __u16 opcode,
+			struct sk_buff *skb)
 {
 	return nci_op_ntf_packet(ndev, opcode, skb, ndev->ops->core_ops,
 				 ndev->ops->n_core_ops);
-- 
1.9.1
