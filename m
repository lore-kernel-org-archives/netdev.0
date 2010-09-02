From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Subject: [PATCH] netns: fix proxy ARP entries listing
Date: Thu, 02 Sep 2010 20:35:01 +0200
Message-ID: <4C7FEE55.8060002@dti2.net>
Reply-To: jorge@dti2.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Linux Network Development list <netdev@vger.kernel.org>,
	stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alcalazamora.dti2.net ([81.24.162.8]:4886 "EHLO
	alcalazamora.dti2.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752146Ab0IBSlo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 14:41:44 -0400
Received: from [172.16.16.6] ([81.24.161.20])
	(authenticated user jorge@dti2.net)
	by alcalazamora.dti2.net (alcalazamora.dti2.net [81.24.162.8])
	(MDaemon PRO v11.0.2)
	with ESMTP id md50010755278.msg
	for <netdev@vger.kernel.org>; Thu, 02 Sep 2010 20:35:04 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Skip entries from foreign network namespaces.

Signed-off-by: Jorge Boncompte [DTI2] <jorge@dti2.net>
---
 net/core/neighbour.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index a4e0a74..4c36fa9 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2323,6 +2323,7 @@ static struct pneigh_entry *pneigh_get_next(struct
seq_file *seq,
        struct net *net = seq_file_net(seq);
        struct neigh_table *tbl = state->tbl;

+restart:
        pn = pn->next;
        while (!pn) {
                if (++state->bucket > PNEIGH_HASHMASK)
@@ -2334,6 +2335,9 @@ static struct pneigh_entry *pneigh_get_next(struct
seq_file *seq,
                        break;
        }

+       if (pn && !net_eq(pneigh_net(pn), net))
+               goto restart;
+
        if (pn && pos)
                --(*pos);

-- 
1.7.1

