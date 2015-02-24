From: Ameen Ali <ameenali023@gmail.com>
Subject: [PATCH 2/2] cosa.c : Array index 'i' is used before limits check.
Date: Tue, 24 Feb 2015 21:52:26 +0200
Message-ID: <1424807546-10013-1-git-send-email-ameenali023@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ameen Ali <ameenali023@gmail.com>,
	Ameen Ali <Ameenali023@gmail.com>
To: kas@fi.muni.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

avoid out-of-bounds-read by checking count before indexing.

Signed-off-by: Ameen Ali <Ameenali023@gmail.com>
---
 drivers/net/wan/cosa.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wan/cosa.c b/drivers/net/wan/cosa.c
index 83c39e2..5252e21 100644
--- a/drivers/net/wan/cosa.c
+++ b/drivers/net/wan/cosa.c
@@ -376,7 +376,7 @@ static int __init cosa_init(void)
 	}
 	for (i=0; i<MAX_CARDS; i++)
 		cosa_cards[i].num = -1;
-	for (i=0; io[i] != 0 && i < MAX_CARDS; i++)
+	for (i=0; (i < MAX_CARDS) && (io[i] != 0) ; i++)
 		cosa_probe(io[i], irq[i], dma[i]);
 	if (!nr_cards) {
 		pr_warn("no devices found\n");
-- 
2.1.0
