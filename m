From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 2/2] e1000: fix mismerge skb_put.
Date: Tue, 18 Apr 2006 12:40:38 -0700
Message-ID: <20060418194038.16262.24957.stgit@gitlost.site>
References: <20060418193950.16262.10757.stgit@gitlost.site>
Cc: "Ronciak, John" <john.ronciak@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kirsher, Jeff" <Jeffrey.t.kirsher@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:4101 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932299AbWDRTgv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2006 15:36:51 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	"Miller, David" <davem@davemloft.net>
In-Reply-To: <20060418193950.16262.10757.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Seems there was a bit of a fix needed to due a bad merge in the legacy
receive path.  Fixes a panic due to skb_over_panic.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 2b8bced..fb8cef6 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3585,8 +3585,7 @@ e1000_clean_rx_irq(struct e1000_adapter 
 				buffer_info->skb = skb;
 				goto next_desc;
 			}
-		} else
-			skb_put(skb, length);
+		}
 
 		/* code added for copybreak, this should improve
 		 * performance for small packets with large amounts



--
Auke Kok <auke-jan.h.kok@intel.com>
Intel Pro Ethernet Driver Group
LAN Access Division / Digital Enterprise Group 
