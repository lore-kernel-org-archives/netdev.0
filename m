From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 23/43 v2] drivers/net/igb: fix sparse warning: symbol shadows
	an earlier one
Date: Wed, 18 Feb 2009 22:49:20 +0100
Message-ID: <20090218214705.8438.48732.stgit@vmbox.hanneseder.net>
References: <20090217.173903.121180042.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:64282 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760790AbZBRVt1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 16:49:27 -0500
In-Reply-To: <20090217.173903.121180042.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Impact: Move variable declaration as far inner as possible.

Fix this sparse warning:
  drivers/net/igb/igb_main.c:1895:21: warning: symbol 'j' shadows an earlier one
  drivers/net/igb/igb_main.c:1855:16: originally declared here

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---

On Wed, Feb 18, 2009 at 2:39 AM, David Miller <davem@davemloft.net> wrote:
> There have been some changes recently to the igb driver so
> this patch no longer applies.

Conflict resolved, should apply now.

Best, -Hannes

 drivers/net/igb/igb_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 43f489a..23431d8 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1973,7 +1973,7 @@ static void igb_configure_rx(struct igb_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 	u32 rctl, rxcsum;
 	u32 rxdctl;
-	int i, j;
+	int i;
 
 	/* disable receives while setting up the descriptors */
 	rctl = rd32(E1000_RCTL);
@@ -1988,7 +1988,7 @@ static void igb_configure_rx(struct igb_adapter *adapter)
 	 * the Base and Length of the Rx Descriptor Ring */
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		struct igb_ring *ring = &adapter->rx_ring[i];
-		j = ring->reg_idx;
+		int j = ring->reg_idx;
 		rdba = ring->dma;
 		wr32(E1000_RDBAL(j),
 		     rdba & 0x00000000ffffffffULL);

