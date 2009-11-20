From: Simon Kagstrom <simon.kagstrom@netinsight.net>
Subject: [PATCH 1/7] via-velocity: Correct setting of skipped checksums
Date: Fri, 20 Nov 2009 16:12:05 +0100
Message-ID: <20091120161205.6ddeb3ff@marrow.netinsight.se>
References: <20091120160633.77b7aee0@marrow.netinsight.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, davej@redhat.com, shemminger@vyatta.com,
	romieu@fr.zoreil.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ernst.netinsight.se ([194.16.221.21]:42331 "HELO
	ernst.netinsight.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753986AbZKTPQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 10:16:41 -0500
In-Reply-To: <20091120160633.77b7aee0@marrow.netinsight.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Taken from the VIA driver). Check that this is actually an UDP or TCP
packet before claiming that the checksum is unnecessary.

Signed-off-by: Simon Kagstrom <simon.kagstrom@netinsight.net>
---
 drivers/net/via-velocity.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index e04e5be..af79969 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -1924,8 +1924,8 @@ static inline void velocity_rx_csum(struct rx_desc *rd, struct sk_buff *skb)
 					(rd->rdesc1.CSM & CSM_UDPKT)) {
 				if (!(rd->rdesc1.CSM & CSM_TUPOK))
 					return;
+				skb->ip_summed = CHECKSUM_UNNECESSARY;
 			}
-			skb->ip_summed = CHECKSUM_UNNECESSARY;
 		}
 	}
 }
-- 
1.6.0.4

