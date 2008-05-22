From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH] RXRPC: Use skb_queue_walk_safe()
Date: Thu, 22 May 2008 18:05:47 +0800
Message-ID: <4835457B.3050300@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-afs@lists.infradead.org, NETDEV <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57156 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1761165AbYEVKIX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 06:08:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Because the list could be modified inside the loop, use
skb_queue_walk_safe().

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 net/rxrpc/ar-ack.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/rxrpc/ar-ack.c b/net/rxrpc/ar-ack.c
index 3ac1672..cbd70d1 100644
--- a/net/rxrpc/ar-ack.c
+++ b/net/rxrpc/ar-ack.c
@@ -468,6 +468,7 @@ static void rxrpc_insert_oos_packet(struct rxrpc_call *call,
 {
 	struct rxrpc_skb_priv *sp, *psp;
 	struct sk_buff *p;
+	struct sk_buff *tmp;
 	u32 seq;
 
 	sp = rxrpc_skb(skb);
@@ -482,7 +483,7 @@ static void rxrpc_insert_oos_packet(struct rxrpc_call *call,
 	/* insert into the buffer in sequence order */
 	spin_lock_bh(&call->lock);
 
-	skb_queue_walk(&call->rx_oos_queue, p) {
+	skb_queue_walk_safe(&call->rx_oos_queue, p, tmp) {
 		psp = rxrpc_skb(p);
 		if (ntohl(psp->hdr.seq) > seq) {
 			_debug("insert oos #%u before #%u",
-- 
1.5.4.rc3

