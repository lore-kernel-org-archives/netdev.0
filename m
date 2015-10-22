From: Robert Dolca <robert.dolca@intel.com>
Subject: [PATCH v4 07/10] nfc: nci: rename nci_prop_ops to nci_driver_ops
Date: Thu, 22 Oct 2015 12:11:39 +0300
Message-ID: <1445505102-16639-8-git-send-email-robert.dolca@intel.com>
References: <1445505102-16639-1-git-send-email-robert.dolca@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org,
	Christophe Ricard <christophe.ricard@gmail.com>,
	Robert Dolca <robert.dolca@intel.com>
To: linux-nfc@lists.01.org,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>,
	Robert Dolca <robert.dolca@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445505102-16639-1-git-send-email-robert.dolca@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Initially it was used to create hooks in the driver for proprietary
operations. Currently it is being used for hooks for both proprietary
and generic operations.

Signed-off-by: Robert Dolca <robert.dolca@intel.com>
---
 drivers/nfc/s3fwrn5/nci.c  |  4 ++--
 drivers/nfc/st-nci/core.c  |  2 +-
 include/net/nfc/nci_core.h |  6 +++---
 net/nfc/nci/core.c         | 16 ++++++++--------
 4 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/nfc/s3fwrn5/nci.c b/drivers/nfc/s3fwrn5/nci.c
index ace0071..075e4e8 100644
--- a/drivers/nfc/s3fwrn5/nci.c
+++ b/drivers/nfc/s3fwrn5/nci.c
@@ -31,7 +31,7 @@ static int s3fwrn5_nci_prop_rsp(struct nci_dev *ndev, struct sk_buff *skb)
 	return 0;
 }
 
-static struct nci_prop_ops s3fwrn5_nci_prop_ops[] = {
+static struct nci_driver_ops s3fwrn5_nci_prop_ops[] = {
 	{
 		.opcode = nci_opcode_pack(NCI_GID_PROPRIETARY,
 				NCI_PROP_AGAIN),
@@ -79,7 +79,7 @@ static struct nci_prop_ops s3fwrn5_nci_prop_ops[] = {
 	},
 };
 
-void s3fwrn5_nci_get_prop_ops(struct nci_prop_ops **ops, size_t *n)
+void s3fwrn5_nci_get_prop_ops(struct nci_driver_ops **ops, size_t *n)
 {
 	*ops = s3fwrn5_nci_prop_ops;
 	*n = ARRAY_SIZE(s3fwrn5_nci_prop_ops);
diff --git a/drivers/nfc/st-nci/core.c b/drivers/nfc/st-nci/core.c
index c419d39..dd7b1c14 100644
--- a/drivers/nfc/st-nci/core.c
+++ b/drivers/nfc/st-nci/core.c
@@ -98,7 +98,7 @@ static int st_nci_prop_rsp_packet(struct nci_dev *ndev,
 	return 0;
 }
 
-static struct nci_prop_ops st_nci_prop_ops[] = {
+static struct nci_driver_ops st_nci_prop_ops[] = {
 	{
 		.opcode = nci_opcode_pack(NCI_GID_PROPRIETARY,
 					  ST_NCI_CORE_PROP),
diff --git a/include/net/nfc/nci_core.h b/include/net/nfc/nci_core.h
index d5a1caa..5daf004 100644
--- a/include/net/nfc/nci_core.h
+++ b/include/net/nfc/nci_core.h
@@ -67,7 +67,7 @@ enum nci_state {
 
 struct nci_dev;
 
-struct nci_prop_ops {
+struct nci_driver_ops {
 	__u16 opcode;
 	int (*rsp)(struct nci_dev *dev, struct sk_buff *skb);
 	int (*ntf)(struct nci_dev *dev, struct sk_buff *skb);
@@ -94,10 +94,10 @@ struct nci_ops {
 	void  (*hci_cmd_received)(struct nci_dev *ndev, u8 pipe, u8 cmd,
 				  struct sk_buff *skb);
 
-	struct nci_prop_ops *prop_ops;
+	struct nci_driver_ops *prop_ops;
 	size_t n_prop_ops;
 
-	struct nci_prop_ops *core_ops;
+	struct nci_driver_ops *core_ops;
 	size_t n_core_ops;
 };
 
diff --git a/net/nfc/nci/core.c b/net/nfc/nci/core.c
index 30c2708..f66a5da 100644
--- a/net/nfc/nci/core.c
+++ b/net/nfc/nci/core.c
@@ -1242,12 +1242,12 @@ int nci_send_cmd(struct nci_dev *ndev, __u16 opcode, __u8 plen, void *payload)
 }
 
 /* Proprietary commands API */
-static struct nci_prop_ops *ops_cmd_lookup(struct nci_prop_ops *ops,
-					   size_t n_ops,
-					   __u16 opcode)
+static struct nci_driver_ops *ops_cmd_lookup(struct nci_driver_ops *ops,
+					     size_t n_ops,
+					     __u16 opcode)
 {
 	size_t i;
-	struct nci_prop_ops *op;
+	struct nci_driver_ops *op;
 
 	if (!ops || !n_ops)
 		return NULL;
@@ -1262,10 +1262,10 @@ static struct nci_prop_ops *ops_cmd_lookup(struct nci_prop_ops *ops,
 }
 
 static int nci_op_rsp_packet(struct nci_dev *ndev, __u16 rsp_opcode,
-			     struct sk_buff *skb, struct nci_prop_ops *ops,
+			     struct sk_buff *skb, struct nci_driver_ops *ops,
 			     size_t n_ops)
 {
-	struct nci_prop_ops *op;
+	struct nci_driver_ops *op;
 
 	op = ops_cmd_lookup(ops, n_ops, rsp_opcode);
 	if (!op || !op->rsp)
@@ -1275,10 +1275,10 @@ static int nci_op_rsp_packet(struct nci_dev *ndev, __u16 rsp_opcode,
 }
 
 static int nci_op_ntf_packet(struct nci_dev *ndev, __u16 ntf_opcode,
-			     struct sk_buff *skb, struct nci_prop_ops *ops,
+			     struct sk_buff *skb, struct nci_driver_ops *ops,
 			     size_t n_ops)
 {
-	struct nci_prop_ops *op;
+	struct nci_driver_ops *op;
 
 	op = ops_cmd_lookup(ops, n_ops, ntf_opcode);
 	if (!op || !op->ntf)
-- 
1.9.1
