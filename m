From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 7/8 net-next-2.6] cxgb3: fix mac index mapping
Date: Tue, 07 Jul 2009 22:49:04 -0700
Message-ID: <20090708054904.11344.40175.stgit@speedy5>
References: <20090708054832.11344.82449.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:19086 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758651AbZGHFtG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2009 01:49:06 -0400
In-Reply-To: <20090708054832.11344.82449.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

Override the mac index computation for the gen2 adapter,
as each port is expected to use index 0.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/t3_hw.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)


diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index 870d449..e78d341 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -3682,6 +3682,8 @@ static void mc7_prep(struct adapter *adapter, struct mc7 *mc7,
 void mac_prep(struct cmac *mac, struct adapter *adapter, int index)
 {
 	mac->adapter = adapter;
+	if (!adapter->params.vpd.xauicfg[1])
+		index = 0;
 	mac->offset = (XGMAC0_1_BASE_ADDR - XGMAC0_0_BASE_ADDR) * index;
 	mac->nucast = 1;
 

