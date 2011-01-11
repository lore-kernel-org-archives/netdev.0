From: kxie@chelsio.com
Subject: [PATCH v2] cxgb3i: fixed connection problem with iscsi private ip
Date: Mon, 10 Jan 2011 16:45:07 -0800
Message-ID: <201101110045.p0B0j7vv016416@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kxie@chelsio.com, davem@davemloft.net,
	James.Bottomley@HansenPartnership.com, michaelc@cs.wisc.edu
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	open-iscsi@googlegroups.com
Return-path: <linux-scsi-owner@vger.kernel.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PATCH v2] cxgb3i: fixed connection problem with iscsi private ip

From: Karen Xie <kxie@chelsio.com>

The last one seems to have some formatting problem. Regenerated the patch.

fixed the connection problem when the private iscsi ipv4 address is provisioned on the interface.

Signed-off-by: Karen Xie <kxie@chelsio.com>
---
 drivers/scsi/cxgbi/cxgb3i/cxgb3i.h |   19 +++++++++++++++----
 1 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/drivers/scsi/cxgbi/cxgb3i/cxgb3i.h b/drivers/scsi/cxgbi/cxgb3i/cxgb3i.h
index 5f5e339..20593fd 100644
--- a/drivers/scsi/cxgbi/cxgb3i/cxgb3i.h
+++ b/drivers/scsi/cxgbi/cxgb3i/cxgb3i.h
@@ -24,10 +24,21 @@
 
 extern cxgb3_cpl_handler_func cxgb3i_cpl_handlers[NUM_CPL_CMDS];
 
-#define cxgb3i_get_private_ipv4addr(ndev) \
-	(((struct port_info *)(netdev_priv(ndev)))->iscsi_ipv4addr)
-#define cxgb3i_set_private_ipv4addr(ndev, addr) \
-	(((struct port_info *)(netdev_priv(ndev)))->iscsi_ipv4addr) = addr
+static inline unsigned int cxgb3i_get_private_ipv4addr(struct net_device *ndev)
+{
+	return ((struct port_info *)(netdev_priv(ndev)))->iscsi_ipv4addr;
+}
+
+static inline void cxgb3i_set_private_ipv4addr(struct net_device *ndev,
+						unsigned int addr)
+{
+	struct port_info *pi =  (struct port_info *)netdev_priv(ndev);
+
+	pi->iscsic.flags = addr ? 1 : 0;
+	pi->iscsi_ipv4addr = addr;
+	if (addr)
+		memcpy(pi->iscsic.mac_addr, ndev->dev_addr, ETH_ALEN);
+}
 
 struct cpl_iscsi_hdr_norss {
 	union opcode_tid ot;
