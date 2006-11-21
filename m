From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Subject: [PATCH 8/11] [SCTP]: Use kzalloc where appropriate
Date: Tue, 21 Nov 2006 01:28:51 -0200
Message-ID: <20061121032851.GI7039@mandriva.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.mandriva.com ([212.85.150.183]:15597 "EHLO mx1.mandriva.com")
	by vger.kernel.org with ESMTP id S1030686AbWKUD25 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Nov 2006 22:28:57 -0500
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/sctp/sm_make_chunk.c |   13 +++++--------
 1 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 9887452..04954e5 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -1279,15 +1279,13 @@ static sctp_cookie_param_t *sctp_pack_co
 			- (bodysize % SCTP_COOKIE_MULTIPLE);
 	*cookie_len = headersize + bodysize;
 
-	retval = kmalloc(*cookie_len, GFP_ATOMIC);
-
-	if (!retval)
-		goto nodata;
-
 	/* Clear this memory since we are sending this data structure
 	 * out on the network.
 	 */
-	memset(retval, 0x00, *cookie_len);
+	retval = kzalloc(*cookie_len, GFP_ATOMIC);
+	if (!retval)
+		goto nodata;
+
 	cookie = (struct sctp_signed_cookie *) retval->body;
 
 	/* Set up the parameter header.  */
@@ -1910,10 +1908,9 @@ int sctp_process_init(struct sctp_associ
 	/* Copy cookie in case we need to resend COOKIE-ECHO. */
 	cookie = asoc->peer.cookie;
 	if (cookie) {
-		asoc->peer.cookie = kmalloc(asoc->peer.cookie_len, gfp);
+		asoc->peer.cookie = kmemdup(cookie, asoc->peer.cookie_len, gfp);
 		if (!asoc->peer.cookie)
 			goto clean_up;
-		memcpy(asoc->peer.cookie, cookie, asoc->peer.cookie_len);
 	}
 
 	/* RFC 2960 7.2.1 The initial value of ssthresh MAY be arbitrarily
-- 
1.4.2.1.g3d5c

