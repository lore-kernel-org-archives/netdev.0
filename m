From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 08/21] e1000: recycle skb
Date: Wed, 21 Jun 2006 22:20:23 -0700
Message-ID: <20060622052022.25497.64883.stgit@gitlost.site>
References: <20060622051815.25497.89192.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:49928 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932803AbWFVFOZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 01:14:25 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060622051815.25497.89192.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Recycle an skb to improve performance a bit.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index fc39cbc..c58fafd 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3604,7 +3604,8 @@ e1000_clean_rx_irq(struct e1000_adapter 
 			/* All receives must fit into a single buffer */
 			E1000_DBG("%s: Receive packet consumed multiple"
 				  " buffers\n", netdev->name);
-			dev_kfree_skb_irq(skb);
+			/* recycle */
+			buffer_info-> skb = skb;
 			goto next_desc;
 		}
 



--
Auke Kok <auke-jan.h.kok@intel.com>
