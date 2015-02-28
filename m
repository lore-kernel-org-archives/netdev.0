From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 2/2] rxrpc: don't multiply with HZ twice
Date: Sat, 28 Feb 2015 11:51:37 +0100
Message-ID: <1425120697-27791-2-git-send-email-fw@strlen.de>
References: <1425120697-27791-1-git-send-email-fw@strlen.de>
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
	Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:49996 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750759AbbB1KwG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2015 05:52:06 -0500
In-Reply-To: <1425120697-27791-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rxrpc_resend_timeout has an initial value of 4 * HZ; use it as-is.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/rxrpc/ar-ack.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/rxrpc/ar-ack.c b/net/rxrpc/ar-ack.c
index 4040418..e0547f5 100644
--- a/net/rxrpc/ar-ack.c
+++ b/net/rxrpc/ar-ack.c
@@ -260,7 +260,7 @@ static void rxrpc_resend(struct rxrpc_call *call)
 				sp->resend_at = jiffies + 3;
 			} else {
 				sp->resend_at =
-					jiffies + rxrpc_resend_timeout * HZ;
+					jiffies + rxrpc_resend_timeout;
 			}
 		}
 
-- 
2.0.5
