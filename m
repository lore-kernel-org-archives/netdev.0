From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 02/10] qlcnic: add api version in reg dump
Date: Tue, 31 Aug 2010 07:29:32 -0700
Message-ID: <1283264980-25881-3-git-send-email-amit.salecha@qlogic.com>
References: <1283264980-25881-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:30288 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1757458Ab0HaO3l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Aug 2010 10:29:41 -0400
In-Reply-To: <1283264980-25881-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h         |    3 ++-
 drivers/net/qlcnic/qlcnic_ethtool.c |    8 ++++++--
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 74eff18..b35fc8e 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -1081,7 +1081,8 @@ struct qlcnic_eswitch {
 #define QLCNIC_SWITCH_PORT_MIRRORING	BIT_4
 };
 
-
+#define QLCNIC_MGMT_API_VERSION	2
+#define QLCNIC_DEV_INFO_SIZE	1
 /* Return codes for Error handling */
 #define QL_STATUS_INVALID_PARAM	-1
 
diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index e294b82..219fe0b 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -117,7 +117,8 @@ static const u32 diag_registers[] = {
 
 static int qlcnic_get_regs_len(struct net_device *dev)
 {
-	return sizeof(diag_registers) + QLCNIC_RING_REGS_LEN;
+	return sizeof(diag_registers) + QLCNIC_RING_REGS_LEN +
+				QLCNIC_DEV_INFO_SIZE + 1;
 }
 
 static int qlcnic_get_eeprom_len(struct net_device *dev)
@@ -345,7 +346,10 @@ qlcnic_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *p)
 	regs->version = (1 << 24) | (adapter->ahw.revision_id << 16) |
 	    (adapter->pdev)->device;
 
-	for (i = 0; diag_registers[i] != -1; i++)
+	regs_buff[0] = (0xcafe0000 | (QLCNIC_DEV_INFO_SIZE & 0xffff));
+	regs_buff[1] = QLCNIC_MGMT_API_VERSION;
+
+	for (i = 2; diag_registers[i] != -1; i++)
 		regs_buff[i] = QLCRD32(adapter, diag_registers[i]);
 
 	if (!test_bit(__QLCNIC_DEV_UP, &adapter->state))
-- 
1.6.0.2

