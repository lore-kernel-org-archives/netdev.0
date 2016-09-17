From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 05/14] rxrpc: Record calls that need to be accepted
Date: Sun, 18 Sep 2016 00:18:19 +0100
Message-ID: <147415429964.17897.13521765826025051919.stgit@warthog.procyon.org.uk>
References: <147415426459.17897.13899206413543061473.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48968 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935460AbcIQXS0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 17 Sep 2016 19:18:26 -0400
In-Reply-To: <147415426459.17897.13899206413543061473.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Record calls that need to be accepted using sk_acceptq_added() otherwise
the backlog counter goes negative because sk_acceptq_removed() is called.
This causes the preallocator to malfunction.

Calls that are preaccepted by AFS within the kernel aren't affected by
this.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/call_accept.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/rxrpc/call_accept.c b/net/rxrpc/call_accept.c
index 26c293ef98eb..323b8da50163 100644
--- a/net/rxrpc/call_accept.c
+++ b/net/rxrpc/call_accept.c
@@ -369,6 +369,8 @@ found_service:
 
 	if (rx->notify_new_call)
 		rx->notify_new_call(&rx->sk, call, call->user_call_ID);
+	else
+		sk_acceptq_added(&rx->sk);
 
 	spin_lock(&conn->state_lock);
 	switch (conn->state) {
