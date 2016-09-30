From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 3/7] rxrpc: Reduce ssthresh to peer's receive window
Date: Fri, 30 Sep 2016 22:40:32 +0100
Message-ID: <147527163239.28826.14579823068242526142.stgit@warthog.procyon.org.uk>
References: <147527161156.28826.2148784664652062075.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60926 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933483AbcI3Vke (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 30 Sep 2016 17:40:34 -0400
In-Reply-To: <147527161156.28826.2148784664652062075.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we receive an ACK from the peer that tells us what the peer's receive
window (rwind) is, we should reduce ssthresh to rwind if rwind is smaller
than ssthresh.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/input.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 21746f0f7ae0..7993473e56bb 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -658,6 +658,8 @@ static void rxrpc_input_ackinfo(struct rxrpc_call *call, struct sk_buff *skb,
 	if (rwind > RXRPC_RXTX_BUFF_SIZE - 1)
 		rwind = RXRPC_RXTX_BUFF_SIZE - 1;
 	call->tx_winsize = rwind;
+	if (call->cong_ssthresh > rwind)
+		call->cong_ssthresh = rwind;
 
 	mtu = min(ntohl(ackinfo->rxMTU), ntohl(ackinfo->maxMTU));
 
