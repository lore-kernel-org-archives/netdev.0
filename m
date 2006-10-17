From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 4/8] e1000: FIX: disable LPE for IPV6, only enable for jumbo frames
Date: Tue, 17 Oct 2006 12:02:41 -0700
Message-ID: <20061017190241.4194.89455.stgit@gitlost.site>
References: <20061017190139.4194.20128.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:17934 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1751432AbWJQSxz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2006 14:53:55 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20061017190139.4194.20128.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Allocations using alloc_page are taking too long for normal MTU, so
use LPE only for jumbo frames. Disable packet split for IPV6 extension
headers since malformed headers can hang the RX.

Signed-off-bu: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index de3dced..f19b43c 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -1808,9 +1808,11 @@ e1000_setup_rctl(struct e1000_adapter *a
 	 * followed by the page buffers.  Therefore, skb->data is
 	 * sized to hold the largest protocol header.
 	 */
+	/* allocations using alloc_page take too long for regular MTU
+	 * so only enable packet split for jumbo frames */
 	pages = PAGE_USE_COUNT(adapter->netdev->mtu);
-	if ((adapter->hw.mac_type > e1000_82547_rev_2) && (pages <= 3) &&
-	    PAGE_SIZE <= 16384)
+	if ((adapter->hw.mac_type >= e1000_82571) && (pages <= 3) &&
+	    PAGE_SIZE <= 16384 && (rctl & E1000_RCTL_LPE))
 		adapter->rx_ps_pages = pages;
 	else
 		adapter->rx_ps_pages = 0;



---
Auke Kok <auke-jan.h.kok@intel.com>
