From: Colin King <colin.king@canonical.com>
Subject: [PATCH] rxrpc: initialize sched to false to ensure it is not a garbage value
Date: Mon,  5 Sep 2016 18:00:02 +0100
Message-ID: <20160905170002.18792-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
        David Howells <dhowells@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:36058 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965514AbcIERB3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Sep 2016 13:01:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

sched will be uninitialized (and contain a garbage value) in the case
where call->state >= RXRPC_CALL_DEAD;  fix this by initializing sched
to false to avoid an inadvertent call to rxrpc_queue_call.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 net/rxrpc/call_object.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index 516d8ea..57e00fc 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -586,7 +586,7 @@ static void rxrpc_dead_call_expired(unsigned long _call)
  */
 static void rxrpc_mark_call_released(struct rxrpc_call *call)
 {
-	bool sched;
+	bool sched = false;
 
 	rxrpc_see_call(call);
 	write_lock(&call->state_lock);
-- 
2.9.3
