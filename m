From: Meelis Roos <mroos@linux.ee>
Subject: [PATCH] warning in SCTP
Date: Thu, 2 Nov 2006 09:29:16 +0200 (EET)
Message-ID: <Pine.SOC.4.61.0611020925530.1919@math.ut.ee>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Return-path: <netdev-owner@vger.kernel.org>
Received: from math.ut.ee ([193.40.36.2]:29406 "EHLO math.ut.ee")
	by vger.kernel.org with ESMTP id S1752709AbWKBH33 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2006 02:29:29 -0500
To: netdev@vger.kernel.org, Sridhar Samudrala <sri@us.ibm.com>,
	lksctp-developers@lists.sourceforge.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


   CC [M]  net/sctp/sm_make_chunk.o
net/sctp/sm_make_chunk.c: In function 'sctp_unpack_cookie':
net/sctp/sm_make_chunk.c:1358: warning: initialization discards qualifiers from pointer target type

The reason is that sctp_unpack_cookie() takes a const struct 
sctp_endpoint and modifies the digest in it (digest being embedded in 
the struct, not a pointer). So sctp_unpack_cookie really does not use 
the argument as const, mark it as such.

Signed-off-by: Meelis Roos <mroos@linux.ee>

diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index de313de..ef80489 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -272,7 +272,7 @@ void sctp_generate_heartbeat_event(unsig

  void sctp_ootb_pkt_free(struct sctp_packet *);

-struct sctp_association *sctp_unpack_cookie(const struct sctp_endpoint *,
+struct sctp_association *sctp_unpack_cookie(struct sctp_endpoint *,
  				       const struct sctp_association *,
  				       struct sctp_chunk *,
  				       gfp_t gfp, int *err,
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 507dff7..3d41a9c 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -1346,7 +1346,7 @@ nodata:

  /* Unpack the cookie from COOKIE ECHO chunk, recreating the association.  */
  struct sctp_association *sctp_unpack_cookie(
-	const struct sctp_endpoint *ep,
+	struct sctp_endpoint *ep,
  	const struct sctp_association *asoc,
  	struct sctp_chunk *chunk, gfp_t gfp,
  	int *error, struct sctp_chunk **errp)

-- 
Meelis Roos (mroos@linux.ee)
