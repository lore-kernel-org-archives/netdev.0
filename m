From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCHv2 NEXT 02/10] qlcnic: add api version in reg dump
Date: Tue, 31 Aug 2010 20:17:45 -0700
Message-ID: <1283311073-7165-3-git-send-email-amit.salecha@qlogic.com>
References: <1283311073-7165-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:22963 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753144Ab0IADRy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Aug 2010 23:17:54 -0400
In-Reply-To: <1283311073-7165-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>

o ethtool reg version bumped to 2

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_ethtool.c |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index e294b82..cb9463b 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -115,9 +115,13 @@ static const u32 diag_registers[] = {
 	-1
 };
 
+#define QLCNIC_MGMT_API_VERSION	2
+#define QLCNIC_DEV_INFO_SIZE	1
+#define QLCNIC_ETHTOOL_REGS_VER	2
 static int qlcnic_get_regs_len(struct net_device *dev)
 {
-	return sizeof(diag_registers) + QLCNIC_RING_REGS_LEN;
+	return sizeof(diag_registers) + QLCNIC_RING_REGS_LEN +
+				QLCNIC_DEV_INFO_SIZE + 1;
 }
 
 static int qlcnic_get_eeprom_len(struct net_device *dev)
@@ -342,10 +346,13 @@ qlcnic_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *p)
 	int ring, i = 0;
 
 	memset(p, 0, qlcnic_get_regs_len(dev));
-	regs->version = (1 << 24) | (adapter->ahw.revision_id << 16) |
-	    (adapter->pdev)->device;
+	regs->version = (QLCNIC_ETHTOOL_REGS_VER << 24) |
+		(adapter->ahw.revision_id << 16) | (adapter->pdev)->device;
 
-	for (i = 0; diag_registers[i] != -1; i++)
+	regs_buff[0] = (0xcafe0000 | (QLCNIC_DEV_INFO_SIZE & 0xffff));
+	regs_buff[1] = QLCNIC_MGMT_API_VERSION;
+
+	for (i = QLCNIC_DEV_INFO_SIZE + 1; diag_registers[i] != -1; i++)
 		regs_buff[i] = QLCRD32(adapter, diag_registers[i]);
 
 	if (!test_bit(__QLCNIC_DEV_UP, &adapter->state))
-- 
1.6.0.2

