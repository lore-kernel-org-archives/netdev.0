From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH net] sctp: Do not try to search for the transport twice
Date: Fri, 28 Aug 2015 21:23:39 -0400
Message-ID: <1440811419-12793-1-git-send-email-vyasevich@gmail.com>
Cc: Vladislav Yasevich <vyasevich@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:33970 "EHLO
	mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750896AbbH2BXs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 21:23:48 -0400
Received: by qkfh127 with SMTP id h127so38199015qkf.1
        for <netdev@vger.kernel.org>; Fri, 28 Aug 2015 18:23:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When removing an non-primary transport during ASCONF
processing, we end up traversing the transport list
twice: once in sctp_cmd_del_non_primary, and once in
sctp_assoc_del_peer.  We can avoid the second
search and call sctp_assoc_rm_peer() instead.
Found by code inspection during code reviews.

Signed-off-by: Vladislav Yasevich <vyasevich@gmail.com>
---
 net/sctp/sm_sideeffect.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index fef2acd..1543cf8 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -954,7 +954,7 @@ static void sctp_cmd_del_non_primary(struct sctp_association *asoc)
 		t = list_entry(pos, struct sctp_transport, transports);
 		if (!sctp_cmp_addr_exact(&t->ipaddr,
 					 &asoc->peer.primary_addr)) {
-			sctp_assoc_del_peer(asoc, &t->ipaddr);
+			sctp_assoc_rm_peer(asoc, t);
 		}
 	}
 }
-- 
1.9.3
