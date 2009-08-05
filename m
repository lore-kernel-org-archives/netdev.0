From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH net-next-2.6] cxgb3: fix 2 ports 1G regression
Date: Wed, 05 Aug 2009 14:59:23 -0700
Message-ID: <20090805215923.21467.99484.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752951AbZHEV73@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

commit 88045b3cf0f8981129cb489c7b6bc36c21dd33a7
	cxgb3: fix mac index mapping

	Override the mac index computation for the gen2 adapter,
	as each port is expected to use index 0.

introduces a regression on 2 port 1G adapter
as its xauicfg vpd value is null.
Add a check on the device id.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/t3_hw.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)


diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index 526e144..032cfe0 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -3692,8 +3692,12 @@ static void mc7_prep(struct adapter *adapter, struct mc7 *mc7,
 
 void mac_prep(struct cmac *mac, struct adapter *adapter, int index)
 {
+	u16 devid;
+
 	mac->adapter = adapter;
-	if (!adapter->params.vpd.xauicfg[1])
+	pci_read_config_word(adapter->pdev, 0x2, &devid);
+
+	if (devid == 0x37 && !adapter->params.vpd.xauicfg[1])
 		index = 0;
 	mac->offset = (XGMAC0_1_BASE_ADDR - XGMAC0_0_BASE_ADDR) * index;
 	mac->nucast = 1;
