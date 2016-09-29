From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 5/6] rxrpc: Request more ACKs in slow-start mode
Date: Thu, 29 Sep 2016 23:16:02 +0100
Message-ID: <147518736231.29235.14244285344986790864.stgit@warthog.procyon.org.uk>
References: <147518732742.29235.11597637573731081178.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37584 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934970AbcI2WQE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Sep 2016 18:16:04 -0400
In-Reply-To: <147518732742.29235.11597637573731081178.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set the request-ACK on more DATA packets whilst we're in slow start mode so
that we get sufficient ACKs back to supply information to configure the
window.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/output.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/rxrpc/output.c b/net/rxrpc/output.c
index ac9a58b619a6..0d47db886f6e 100644
--- a/net/rxrpc/output.c
+++ b/net/rxrpc/output.c
@@ -284,6 +284,7 @@ int rxrpc_send_data_packet(struct rxrpc_call *call, struct sk_buff *skb,
 	 * ACKs if a DATA packet appears to have been lost.
 	 */
 	if (retrans ||
+	    call->cong_mode == RXRPC_CALL_SLOW_START ||
 	    (call->peer->rtt_usage < 3 && sp->hdr.seq & 1) ||
 	    ktime_before(ktime_add_ms(call->peer->rtt_last_req, 1000),
 			 ktime_get_real()))
