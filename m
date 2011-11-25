From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Subject: [PATCH v2] netns: fix proxy ARP entries listing on a netns
Date: Fri, 25 Nov 2011 15:41:29 +0100
Message-ID: <1322232089-31902-1-git-send-email-jorge@dti2.net>
References: <20111123.173613.1360696422325749253.davem@davemloft.net>
Reply-To: jorge@dti2.net
Cc: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alcalazamora.dti2.net ([81.24.162.8]:64747 "EHLO
	alcalazamora.dti2.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755468Ab1KYOr1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2011 09:47:27 -0500
Received: from nikopol.intranet.dti2.net ([81.24.160.13])
	(authenticated user jorge@dti2.net)
	by alcalazamora.dti2.net (alcalazamora.dti2.net [81.24.162.8])
	(MDaemon PRO v12.5.0)
	with ESMTP id md50019844272.msg
	for <netdev@vger.kernel.org>; Fri, 25 Nov 2011 15:41:50 +0100
In-Reply-To: <20111123.173613.1360696422325749253.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>

Skip entries from foreign network namespaces.

V2:
    Fixed as suggested by David Miller to avoid a goto.

Signed-off-by: Jorge Boncompte [DTI2] <jorge@dti2.net>
---
 net/core/neighbour.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 2684794..27d3fef 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2414,7 +2414,10 @@ static struct pneigh_entry *pneigh_get_next(struct seq_file *seq,
 	struct net *net = seq_file_net(seq);
 	struct neigh_table *tbl = state->tbl;
 
-	pn = pn->next;
+	do {
+		pn = pn->next;
+	} while (pn && !net_eq(pneigh_net(pn), net));
+
 	while (!pn) {
 		if (++state->bucket > PNEIGH_HASHMASK)
 			break;
-- 
1.7.7.1
