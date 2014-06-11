From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH v3 net-next 5/5] net: sctp: fix incorrect type in gfp initializer
Date: Wed, 11 Jun 2014 18:19:32 +0200
Message-ID: <1402503572-32237-6-git-send-email-dborkman@redhat.com>
References: <1402503572-32237-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40203 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933117AbaFKQTn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2014 12:19:43 -0400
In-Reply-To: <1402503572-32237-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes the following sparse warning:

  net/sctp/associola.c:1556:29: warning: incorrect type in initializer (different base types)
  net/sctp/associola.c:1556:29:    expected bool [unsigned] [usertype] preload
  net/sctp/associola.c:1556:29:    got restricted gfp_t

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/sctp/associola.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 58bbb73..9e0509c 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -1591,7 +1591,7 @@ int sctp_assoc_lookup_laddr(struct sctp_association *asoc,
 /* Set an association id for a given association */
 int sctp_assoc_set_id(struct sctp_association *asoc, gfp_t gfp)
 {
-	bool preload = gfp & __GFP_WAIT;
+	bool preload = !!(gfp & __GFP_WAIT);
 	int ret;
 
 	/* If the id is already assigned, keep it. */
-- 
1.7.11.7
