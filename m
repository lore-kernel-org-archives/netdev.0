From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net PATCH v2 6/7] bnx2x: fix registers dumped
Date: Tue, 11 Sep 2012 17:34:13 +0300
Message-ID: <1347374054-16730-7-git-send-email-yuvalmin@broadcom.com>
References: <1347374054-16730-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3253 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759287Ab2IKO6r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Sep 2012 10:58:47 -0400
In-Reply-To: <1347374054-16730-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

Under traffic, there are several registers that when read (e.g., via
'ethtool -d') may cause the chip to stall.
This patch corrects the registers read in such flows.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dump.h   |   25 ++++++-------------
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |    2 +-
 2 files changed, 9 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dump.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dump.h
index 3e4cff9..b926f58 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dump.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dump.h
@@ -401,11 +401,11 @@ static const struct reg_addr reg_addrs[] = {
 	{ 0x70000, 8, RI_ALL_ONLINE },
 	{ 0x70020, 8184, RI_ALL_OFFLINE },
 	{ 0x78000, 8192, RI_E3E3B0_OFFLINE },
-	{ 0x85000, 3, RI_ALL_ONLINE },
-	{ 0x8501c, 7, RI_ALL_ONLINE },
-	{ 0x85048, 1, RI_ALL_ONLINE },
-	{ 0x85200, 32, RI_ALL_ONLINE },
-	{ 0xb0000, 16384, RI_E1H_ONLINE },
+	{ 0x85000, 3, RI_ALL_OFFLINE },
+	{ 0x8501c, 7, RI_ALL_OFFLINE },
+	{ 0x85048, 1, RI_ALL_OFFLINE },
+	{ 0x85200, 32, RI_ALL_OFFLINE },
+	{ 0xb0000, 16384, RI_E1H_OFFLINE },
 	{ 0xc1000, 7, RI_ALL_ONLINE },
 	{ 0xc103c, 2, RI_E2E3E3B0_ONLINE },
 	{ 0xc1800, 2, RI_ALL_ONLINE },
@@ -581,17 +581,12 @@ static const struct reg_addr reg_addrs[] = {
 	{ 0x140188, 3, RI_E1E1HE2E3_ONLINE },
 	{ 0x140194, 13, RI_ALL_ONLINE },
 	{ 0x140200, 6, RI_E1E1HE2E3_ONLINE },
-	{ 0x140220, 4, RI_E2E3_ONLINE },
-	{ 0x140240, 4, RI_E2E3_ONLINE },
 	{ 0x140260, 4, RI_E2E3_ONLINE },
 	{ 0x140280, 4, RI_E2E3_ONLINE },
-	{ 0x1402a0, 4, RI_E2E3_ONLINE },
-	{ 0x1402c0, 4, RI_E2E3_ONLINE },
 	{ 0x1402e0, 2, RI_E2E3_ONLINE },
 	{ 0x1402e8, 2, RI_E2E3E3B0_ONLINE },
 	{ 0x1402f0, 9, RI_E2E3_ONLINE },
 	{ 0x140314, 44, RI_E3B0_ONLINE },
-	{ 0x1403d0, 70, RI_E3B0_ONLINE },
 	{ 0x144000, 4, RI_E1E1H_ONLINE },
 	{ 0x148000, 4, RI_E1E1H_ONLINE },
 	{ 0x14c000, 4, RI_E1E1H_ONLINE },
@@ -704,7 +699,6 @@ static const struct reg_addr reg_addrs[] = {
 	{ 0x180398, 1, RI_E2E3E3B0_ONLINE },
 	{ 0x1803a0, 5, RI_E2E3E3B0_ONLINE },
 	{ 0x1803b4, 2, RI_E3E3B0_ONLINE },
-	{ 0x180400, 1, RI_ALL_ONLINE },
 	{ 0x180404, 255, RI_E1E1H_OFFLINE },
 	{ 0x181000, 4, RI_ALL_ONLINE },
 	{ 0x181010, 1020, RI_ALL_OFFLINE },
@@ -800,9 +794,9 @@ static const struct reg_addr reg_addrs[] = {
 	{ 0x1b905c, 1, RI_E3E3B0_ONLINE },
 	{ 0x1b9064, 1, RI_E3B0_ONLINE },
 	{ 0x1b9080, 10, RI_E3B0_ONLINE },
-	{ 0x1b9400, 14, RI_E2E3E3B0_ONLINE },
-	{ 0x1b943c, 19, RI_E2E3E3B0_ONLINE },
-	{ 0x1b9490, 10, RI_E2E3E3B0_ONLINE },
+	{ 0x1b9400, 14, RI_E2E3E3B0_OFFLINE },
+	{ 0x1b943c, 19, RI_E2E3E3B0_OFFLINE },
+	{ 0x1b9490, 10, RI_E2E3E3B0_OFFLINE },
 	{ 0x1c0000, 2, RI_ALL_ONLINE },
 	{ 0x200000, 65, RI_ALL_ONLINE },
 	{ 0x20014c, 2, RI_E1HE2E3E3B0_ONLINE },
@@ -814,7 +808,6 @@ static const struct reg_addr reg_addrs[] = {
 	{ 0x200398, 1, RI_E2E3E3B0_ONLINE },
 	{ 0x2003a0, 1, RI_E2E3E3B0_ONLINE },
 	{ 0x2003a8, 2, RI_E2E3E3B0_ONLINE },
-	{ 0x200400, 1, RI_ALL_ONLINE },
 	{ 0x200404, 255, RI_E1E1H_OFFLINE },
 	{ 0x202000, 4, RI_ALL_ONLINE },
 	{ 0x202010, 2044, RI_ALL_OFFLINE },
@@ -921,7 +914,6 @@ static const struct reg_addr reg_addrs[] = {
 	{ 0x280398, 1, RI_E2E3E3B0_ONLINE },
 	{ 0x2803a0, 1, RI_E2E3E3B0_ONLINE },
 	{ 0x2803a8, 2, RI_E2E3E3B0_ONLINE },
-	{ 0x280400, 1, RI_ALL_ONLINE },
 	{ 0x280404, 255, RI_E1E1H_OFFLINE },
 	{ 0x282000, 4, RI_ALL_ONLINE },
 	{ 0x282010, 2044, RI_ALL_OFFLINE },
@@ -1031,7 +1023,6 @@ static const struct reg_addr reg_addrs[] = {
 	{ 0x300398, 1, RI_E2E3E3B0_ONLINE },
 	{ 0x3003a0, 1, RI_E2E3E3B0_ONLINE },
 	{ 0x3003a8, 2, RI_E2E3E3B0_ONLINE },
-	{ 0x300400, 1, RI_ALL_ONLINE },
 	{ 0x300404, 255, RI_E1E1H_OFFLINE },
 	{ 0x302000, 4, RI_ALL_ONLINE },
 	{ 0x302010, 2044, RI_ALL_OFFLINE },
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index bbf4cf0..ebf40cd 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -775,7 +775,7 @@ static void bnx2x_get_regs(struct net_device *dev,
 	struct bnx2x *bp = netdev_priv(dev);
 	struct dump_hdr dump_hdr = {0};
 
-	regs->version = 0;
+	regs->version = 1;
 	memset(p, 0, regs->len);
 
 	if (!netif_running(bp->dev))
-- 
1.7.9.rc2
