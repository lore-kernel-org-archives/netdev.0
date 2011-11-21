From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Subject: [PATCH] netns: fix proxy ARP entries listing on a netns
Date: Mon, 21 Nov 2011 20:46:14 +0100
Message-ID: <1321904774-3030-1-git-send-email-jorge@dti2.net>
Reply-To: jorge@dti2.net
Cc: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alcalazamora.dti2.net ([81.24.162.8]:54732 "EHLO
	alcalazamora.dti2.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753095Ab1KUTqV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 14:46:21 -0500
Received: from nikopol.intranet.dti2.net ([81.24.160.13])
	(authenticated user jorge@dti2.net)
	by alcalazamora.dti2.net (alcalazamora.dti2.net [81.24.162.8])
	(MDaemon PRO v12.5.0)
	with ESMTP id md50019764265.msg
	for <netdev@vger.kernel.org>; Mon, 21 Nov 2011 20:46:18 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>

Skip entries from foreign network namespaces.

Signed-off-by: Jorge Boncompte [DTI2] <jorge@dti2.net>
---
 net/core/neighbour.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 039d51e..2adcbeb 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2397,6 +2397,7 @@ static struct pneigh_entry *pneigh_get_next(struct seq_file *seq,
 	struct net *net = seq_file_net(seq);
 	struct neigh_table *tbl = state->tbl;
 
+restart:
 	pn = pn->next;
 	while (!pn) {
 		if (++state->bucket > PNEIGH_HASHMASK)
@@ -2408,6 +2409,9 @@ static struct pneigh_entry *pneigh_get_next(struct seq_file *seq,
 			break;
 	}
 
+	if (pn && !net_eq(pneigh_net(pn), net))
+		goto restart;
+
 	if (pn && pos)
 		--(*pos);
 
-- 
1.7.7.1
