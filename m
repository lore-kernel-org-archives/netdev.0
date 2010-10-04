From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 3/9] qlcnic: fix diag register
Date: Mon,  4 Oct 2010 06:45:31 -0700
Message-ID: <1286199938-17367-4-git-send-email-amit.salecha@qlogic.com>
References: <1286199938-17367-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:20844 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755351Ab0JDNpo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Oct 2010 09:45:44 -0400
In-Reply-To: <1286199938-17367-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

regs_buff[i] and diag_registers[j] array should use different index
variable.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_ethtool.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index 550cfe9..6a76014 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -343,7 +343,7 @@ qlcnic_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *p)
 	struct qlcnic_recv_context *recv_ctx = &adapter->recv_ctx;
 	struct qlcnic_host_sds_ring *sds_ring;
 	u32 *regs_buff = p;
-	int ring, i = 0;
+	int ring, i = 0, j = 0;
 
 	memset(p, 0, qlcnic_get_regs_len(dev));
 	regs->version = (QLCNIC_ETHTOOL_REGS_VER << 24) |
@@ -352,8 +352,8 @@ qlcnic_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *p)
 	regs_buff[0] = (0xcafe0000 | (QLCNIC_DEV_INFO_SIZE & 0xffff));
 	regs_buff[1] = QLCNIC_MGMT_API_VERSION;
 
-	for (i = QLCNIC_DEV_INFO_SIZE + 1; diag_registers[i] != -1; i++)
-		regs_buff[i] = QLCRD32(adapter, diag_registers[i]);
+	for (i = QLCNIC_DEV_INFO_SIZE + 1; diag_registers[j] != -1; j++, i++)
+		regs_buff[i] = QLCRD32(adapter, diag_registers[j]);
 
 	if (!test_bit(__QLCNIC_DEV_UP, &adapter->state))
 		return;
-- 
1.6.0.2

