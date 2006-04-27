From: Patrick Caulfield <patrick@tykepenguin.com>
Subject: [PATCH] DECnet: Fix level1 router hello
Date: Thu, 27 Apr 2006 13:37:23 +0100
Message-ID: <4450BB03.4050404@tykepenguin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Steven Whitehouse <steve@chygwyn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spc1-leed3-0-0-cust958.seac.broadband.ntl.com ([82.8.19.191]:60398
	"EHLO fentible.pjc.net") by vger.kernel.org with ESMTP
	id S965117AbWD0Mh2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Apr 2006 08:37:28 -0400
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes hello messages sent when a node is a level 1 router. Slightly
contrary to the spec (maybe) VMS ignores hello messages that do not name
level2 routers that it also knows about.

So, here we simply name all the routers that the node knows about rather just
other level1 routers.
(I hope the patch is clearer than the description. sorry).

Patrick

Signed-off-by: Patrick Caulfield <patrick@tykepenguin.com>

diff --git a/net/decnet/dn_neigh.c b/net/decnet/dn_neigh.c
index 7c8692c..66e230c 100644
--- a/net/decnet/dn_neigh.c
+++ b/net/decnet/dn_neigh.c
@@ -493,7 +493,6 @@ struct elist_cb_state {
 static void neigh_elist_cb(struct neighbour *neigh, void *_info)
 {
 	struct elist_cb_state *s = _info;
-	struct dn_dev *dn_db;
 	struct dn_neigh *dn;

 	if (neigh->dev != s->dev)
@@ -503,10 +502,6 @@ static void neigh_elist_cb(struct neighb
 	if (!(dn->flags & (DN_NDFLAG_R1|DN_NDFLAG_R2)))
 		return;

-	dn_db = (struct dn_dev *) s->dev->dn_ptr;
-	if (dn_db->parms.forwarding == 1 && (dn->flags & DN_NDFLAG_R2))
-		return;
-
 	if (s->t == s->n)
 		s->rs = dn_find_slot(s->ptr, s->n, dn->priority);
 	else

