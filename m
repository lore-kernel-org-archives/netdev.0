From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 12/13] cxgb3 - log and clear PEX errors
Date: Fri, 10 Aug 2007 23:30:31 -0700
Message-ID: <20070811063031.8221.70512.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:4346 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752391AbXHKGaf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Aug 2007 02:30:35 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Clear pciE PEX errors late at module load time.
Log details when PEX errors occur.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/t3_hw.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index 3d47627..538b254 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -1355,6 +1355,10 @@ static void pcie_intr_handler(struct adapter *adapter)
 		{0}
 	};
 
+	if (t3_read_reg(adapter, A_PCIE_INT_CAUSE) & F_PEXERR)
+		CH_ALERT(adapter, "PEX error code 0x%x\n",
+			 t3_read_reg(adapter, A_PCIE_PEX_ERR));
+
 	if (t3_handle_intr_status(adapter, A_PCIE_INT_CAUSE, PCIE_INTR_MASK,
 				  pcie_intr_info, adapter->irq_stats))
 		t3_fatal_err(adapter);
@@ -1806,6 +1810,8 @@ void t3_intr_clear(struct adapter *adapter)
 	for (i = 0; i < ARRAY_SIZE(cause_reg_addr); ++i)
 		t3_write_reg(adapter, cause_reg_addr[i], 0xffffffff);
 
+	if (is_pcie(adapter))
+		t3_write_reg(adapter, A_PCIE_PEX_ERR, 0xffffffff);
 	t3_write_reg(adapter, A_PL_INT_CAUSE0, 0xffffffff);
 	t3_read_reg(adapter, A_PL_INT_CAUSE0);	/* flush */
 }
