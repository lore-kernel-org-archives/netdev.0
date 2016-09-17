From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 13/14] rxrpc: Be consistent about switch value in
 rxrpc_send_call_packet()
Date: Sun, 18 Sep 2016 00:19:14 +0100
Message-ID: <147415435469.17897.12442015852819757874.stgit@warthog.procyon.org.uk>
References: <147415426459.17897.13899206413543061473.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50714 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755372AbcIQXTQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 17 Sep 2016 19:19:16 -0400
In-Reply-To: <147415426459.17897.13899206413543061473.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rxrpc_send_call_packet() should use type in both its switch-statements
rather than using pkt->whdr.type.  This might give the compiler an easier
job of uninitialised variable checking.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/output.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/rxrpc/output.c b/net/rxrpc/output.c
index aa0507214b31..0b21ed859de7 100644
--- a/net/rxrpc/output.c
+++ b/net/rxrpc/output.c
@@ -182,7 +182,7 @@ int rxrpc_send_call_packet(struct rxrpc_call *call, u8 type)
 			     &msg, iov, ioc, len);
 
 	if (ret < 0 && call->state < RXRPC_CALL_COMPLETE) {
-		switch (pkt->whdr.type) {
+		switch (type) {
 		case RXRPC_PACKET_TYPE_ACK:
 			rxrpc_propose_ACK(call, pkt->ack.reason,
 					  ntohs(pkt->ack.maxSkew),
