From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: [PATCH 2/3] NIU: Implement discard counters, info/debug statements.
Date: Thu, 18 Dec 2008 14:56:18 +0100
Message-ID: <1229608578.16904.28.camel@localhost.localdomain>
References: <1229608331.16904.23.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, hawk@comx.dk
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:32841 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751483AbYLRN4T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2008 08:56:19 -0500
In-Reply-To: <1229608331.16904.23.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Discard packet counter debug statements that can be turned on
runtime, by users to assist debugging of the driver code.

Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---

 drivers/net/niu.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 1bd7018..9f6a98f 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -3560,6 +3560,9 @@ static inline void niu_sync_rx_discard_stats(struct niu *np,
 		if (unlikely(misc & RXMISC_OFLOW))
 			dev_err(np->device, "rx-%d: Counter overflow "
 				"RXMISC discard\n", rx_channel);
+
+		niudbg(RX_ERR, "%s-rx-%d: MISC drop=%u over=%u\n",
+		       np->dev->name, rx_channel, misc, misc-limit);
 	}
 
 	/* WRED (Weighted Random Early Discard) by hardware */
@@ -3571,6 +3574,9 @@ static inline void niu_sync_rx_discard_stats(struct niu *np,
 		if (unlikely(wred & RED_DIS_CNT_OFLOW))
 			dev_err(np->device, "rx-%d: Counter overflow "
 				"WRED discard\n", rx_channel);
+
+		niudbg(RX_ERR, "%s-rx-%d: WRED drop=%u over=%u\n",
+		       np->dev->name, rx_channel, wred, wred-limit);
 	}
 }
 


