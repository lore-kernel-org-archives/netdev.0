From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 05/18] e1000: add mmiowb() for IA64 to sync tail writes
Date: Wed, 01 Nov 2006 09:51:39 -0800
Message-ID: <20061101175139.2356.14656.stgit@gitlost.site>
References: <20061101175043.2356.13659.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:17168 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1946963AbWKARof (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2006 12:44:35 -0500
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20061101175043.2356.13659.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


IA64 SMP systems were seeing TX issues with multiple cpu's attempting
to write tail registers unordered. This mmiowb() fixes the issue.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
---

 drivers/net/e1000/e1000_main.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 194a07d..54e384b 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2867,6 +2867,9 @@ e1000_tx_queue(struct e1000_adapter *ada
 
 	tx_ring->next_to_use = i;
 	writel(i, adapter->hw.hw_addr + tx_ring->tdt);
+	/* we need this if more than one processor can write to our tail
+	 * at a time, it syncronizes IO on IA64/Altix systems */
+	mmiowb();
 }
 
 /**



---
Auke Kok <auke-jan.h.kok@intel.com>
