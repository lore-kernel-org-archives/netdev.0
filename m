From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 2/2] net: sctp: minor: make sctp_ep_common's member 'dead' a bool
Date: Mon, 15 Apr 2013 15:27:18 +0200
Message-ID: <1366032438-4412-2-git-send-email-dborkman@redhat.com>
References: <1366032438-4412-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57706 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750827Ab3DON1Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Apr 2013 09:27:24 -0400
In-Reply-To: <1366032438-4412-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since dead only holds two states (0,1), make it a bool instead
of a 'char', which is more appropriate for its purpose.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/net/sctp/structs.h | 2 +-
 net/sctp/associola.c       | 4 ++--
 net/sctp/endpointola.c     | 4 ++--
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 3e80eed..e12aa77 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1176,7 +1176,7 @@ struct sctp_ep_common {
 	 *   dead     - Do not attempt to use this object.
 	 */
 	atomic_t    refcnt;
-	char	    dead;
+	bool	    dead;
 
 	/* What socket does this endpoint belong to?  */
 	struct sock *sk;
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index b893aa6..423549a 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -104,7 +104,7 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
 
 	/* Initialize the object handling fields.  */
 	atomic_set(&asoc->base.refcnt, 1);
-	asoc->base.dead = 0;
+	asoc->base.dead = false;
 
 	/* Initialize the bind addr area.  */
 	sctp_bind_addr_init(&asoc->base.bind_addr, ep->base.bind_addr.port);
@@ -407,7 +407,7 @@ void sctp_association_free(struct sctp_association *asoc)
 	/* Mark as dead, so other users can know this structure is
 	 * going away.
 	 */
-	asoc->base.dead = 1;
+	asoc->base.dead = true;
 
 	/* Dispose of any data lying around in the outqueue. */
 	sctp_outq_free(&asoc->outqueue);
diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
index 46bbfc2..5fbd7bc 100644
--- a/net/sctp/endpointola.c
+++ b/net/sctp/endpointola.c
@@ -121,7 +121,7 @@ static struct sctp_endpoint *sctp_endpoint_init(struct sctp_endpoint *ep,
 
 	/* Initialize the basic object fields. */
 	atomic_set(&ep->base.refcnt, 1);
-	ep->base.dead = 0;
+	ep->base.dead = false;
 
 	/* Create an input queue.  */
 	sctp_inq_init(&ep->base.inqueue);
@@ -233,7 +233,7 @@ void sctp_endpoint_add_asoc(struct sctp_endpoint *ep,
  */
 void sctp_endpoint_free(struct sctp_endpoint *ep)
 {
-	ep->base.dead = 1;
+	ep->base.dead = true;
 
 	ep->base.sk->sk_state = SCTP_SS_CLOSED;
 
-- 
1.7.11.7
