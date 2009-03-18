From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH] fix sctp breakage
Date: Wed, 18 Mar 2009 03:14:05 +0000
Message-ID: <20090318031405.GX28946@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:37111 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756072AbZCRDOK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 23:14:10 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

broken by commit 5e739d1752aca4e8f3e794d431503bfca3162df4; AFAICS should
be -stable fodder as well...

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
index 4c8d9f4..905fda5 100644
--- a/net/sctp/endpointola.c
+++ b/net/sctp/endpointola.c
@@ -111,7 +111,8 @@ static struct sctp_endpoint *sctp_endpoint_init(struct sctp_endpoint *ep,
 		if (sctp_addip_enable) {
 			auth_chunks->chunks[0] = SCTP_CID_ASCONF;
 			auth_chunks->chunks[1] = SCTP_CID_ASCONF_ACK;
-			auth_chunks->param_hdr.length += htons(2);
+			auth_chunks->param_hdr.length =
+					htons(sizeof(sctp_paramhdr_t) + 2);
 		}
 	}
 
