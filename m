From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH net-next 3/10] cxgb3: fix skb truesize in jumbo mode
Date: Fri, 13 Mar 2009 00:13:54 -0700
Message-ID: <20090313071354.21994.36111.stgit@speedy5>
References: <20090313071343.21994.85719.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:27598 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751267AbZCMHN5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 03:13:57 -0400
In-Reply-To: <20090313071343.21994.85719.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

Update skb truesize correctly for the 2nd buffer from a Jumbo frame

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/sge.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 808b8af..90f6f82 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -830,14 +830,15 @@ recycle:
 				   len - SGE_RX_PULL_LEN);
 		newskb->len = len;
 		newskb->data_len = len - SGE_RX_PULL_LEN;
+		newskb->truesize += newskb->data_len;
 	} else {
 		skb_fill_page_desc(newskb, skb_shinfo(newskb)->nr_frags,
 				   sd->pg_chunk.page,
 				   sd->pg_chunk.offset, len);
 		newskb->len += len;
 		newskb->data_len += len;
+		newskb->truesize += len;
 	}
-	newskb->truesize += newskb->data_len;
 
 	fl->credits--;
 	/*

