From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 10/14] rxrpc: Fix the parsing of soft-ACKs
Date: Sun, 18 Sep 2016 00:18:53 +0100
Message-ID: <147415433385.17897.13844511631257470101.stgit@warthog.procyon.org.uk>
References: <147415426459.17897.13899206413543061473.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53136 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S936111AbcIQXSz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 17 Sep 2016 19:18:55 -0400
In-Reply-To: <147415426459.17897.13899206413543061473.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The soft-ACK parser doesn't increment the pointer into the soft-ACK list,
resulting in the first ACK/NACK value being applied to all the relevant
packets in the Tx queue.  This has the potential to miss retransmissions
and cause excessive retransmissions.

Fix this by incrementing the pointer.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/input.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index f0d9115b9b7e..c1f83d22f9b7 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -384,7 +384,7 @@ static void rxrpc_input_soft_acks(struct rxrpc_call *call, u8 *acks,
 
 	for (; nr_acks > 0; nr_acks--, seq++) {
 		ix = seq & RXRPC_RXTX_BUFF_MASK;
-		switch (*acks) {
+		switch (*acks++) {
 		case RXRPC_ACK_TYPE_ACK:
 			call->rxtx_annotations[ix] = RXRPC_TX_ANNO_ACK;
 			break;
