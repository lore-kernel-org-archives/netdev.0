From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 5/8] e1000: FIX: Don't limit descriptor size to 4kb for PCI-E adapters
Date: Tue, 17 Oct 2006 12:02:43 -0700
Message-ID: <20061017190243.4194.40205.stgit@gitlost.site>
References: <20061017190139.4194.20128.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:19470 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1751438AbWJQSyw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2006 14:54:52 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20061017190139.4194.20128.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


82571 and newer chispets don't need to limit desc. length to 4kb and can
handle 8kb sizes.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index f19b43c..95bbb2d 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2992,6 +2992,11 @@ e1000_xmit_frame(struct sk_buff *skb, st
 		return NETDEV_TX_OK;
 	}
 
+	/* 82571 and newer doesn't need the workaround that limited descriptor
+	 * length to 4kB */
+	if (adapter->hw.mac_type >= e1000_82571)
+		max_per_txd = 8192;
+
 #ifdef NETIF_F_TSO
 	mss = skb_shinfo(skb)->gso_size;
 	/* The controller does a simple calculation to



---
Auke Kok <auke-jan.h.kok@intel.com>
