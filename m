From: Corcodel Marian <asd@marian1000.go.ro>
Subject: [PATCH net v3.16]r8169: Keep minimum barrier on coherent allocation
Date: Tue,  1 Mar 2016 18:32:11 +0200
Message-ID: <1456849931-9533-1-git-send-email-asd@marian1000.go.ro>
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Corcodel Marian <asd@marian1000.go.ro>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [82.78.245.130] ([82.78.245.130]:47443 "EHLO marian1000.go.ro"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751062AbcCAQdH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Mar 2016 11:33:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This patch add 256 Bytes barrier on rx/tx coherent allocations.

Signed-off-by: Corcodel Marian <asd@marian1000.go.ro>
---
 drivers/net/ethernet/realtek/r8169.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 5fd3fca..aeca4fb 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -86,8 +86,8 @@ static const int multicast_filter_limit = 32;
 #define R8169_NAPI_WEIGHT	64
 #define NUM_TX_DESC	1024	/* Number of Tx descriptor registers */
 #define NUM_RX_DESC	1024U	/* Number of Rx descriptor registers */
-#define R8169_TX_RING_BYTES	(NUM_TX_DESC * sizeof(struct TxDesc))
-#define R8169_RX_RING_BYTES	(NUM_RX_DESC * sizeof(struct RxDesc))
+#define R8169_TX_RING_BYTES	ALIGN((NUM_TX_DESC * sizeof(struct TxDesc)), 256)
+#define R8169_RX_RING_BYTES	ALIGN((NUM_RX_DESC * sizeof(struct RxDesc)), 256)
 
 #define RTL8169_TX_TIMEOUT	(6*HZ)
 #define RTL8169_PHY_TIMEOUT	(10*HZ)
-- 
2.1.4
