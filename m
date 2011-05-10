From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 10/21] tipc: Fix problem with bundled multicast message
Date: Tue, 10 May 2011 16:44:26 -0400
Message-ID: <1305060277-15600-11-git-send-email-paul.gortmaker@windriver.com>
References: <1305060277-15600-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Allan Stephens <allan.stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:52380 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752388Ab1EJUpD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 16:45:03 -0400
In-Reply-To: <1305060277-15600-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Set the destination node and destination port fields of an outgoing
multicast message header to zero; this is necessary to ensure that
the receiving node can route the message properly if it was packed
into a bundle due to link congestion. (Previously, there was a chance
that the receiving node would send the unbundled message to a random
node & port, rather than processing the message itself.)

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/port.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/tipc/port.c b/net/tipc/port.c
index c2229c4..ac64037 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -92,6 +92,8 @@ int tipc_multicast(u32 ref, struct tipc_name_seq const *seq,
 	hdr = &oport->phdr;
 	msg_set_type(hdr, TIPC_MCAST_MSG);
 	msg_set_lookup_scope(hdr, TIPC_CLUSTER_SCOPE);
+	msg_set_destport(hdr, 0);
+	msg_set_destnode(hdr, 0);
 	msg_set_nametype(hdr, seq->type);
 	msg_set_namelower(hdr, seq->lower);
 	msg_set_nameupper(hdr, seq->upper);
-- 
1.7.4.4

