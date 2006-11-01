From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 08/18] e1000: simplify skb_put call.
Date: Wed, 01 Nov 2006 09:51:46 -0800
Message-ID: <20061101175146.2356.57899.stgit@gitlost.site>
References: <20061101175043.2356.13659.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:18704 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1946968AbWKARoi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2006 12:44:38 -0500
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20061101175043.2356.13659.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Simplify two calls to skb_put by removing one call to it.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 54e384b..7f3d243 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3842,12 +3842,11 @@ e1000_clean_rx_irq(struct e1000_adapter 
 				/* save the skb in buffer_info as good */
 				buffer_info->skb = skb;
 				skb = new_skb;
-				skb_put(skb, length);
 			}
-		} else
-			skb_put(skb, length);
-
+			/* else just continue with the old one */
+		}
 		/* end copybreak code */
+		skb_put(skb, length);
 
 		/* Receive Checksum Offload */
 		e1000_rx_checksum(adapter,



---
Auke Kok <auke-jan.h.kok@intel.com>
