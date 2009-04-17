From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: [PATCH] ax25: proc uid file misses header
Date: Fri, 17 Apr 2009 15:19:36 +0100
Message-ID: <20090417141928.15105.59684.stgit@t61.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:37307 "EHLO
	t61.ukuu.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756821AbZDQNTy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 09:19:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This has been broken for a while. I happened to catch it testing because one
app "knew" that the top line of the calls data was the policy line and got
confused.

Put the header back.

Signed-off-by: Alan Cox <alan@lxorguk.ukuu.org.uk>
---

 net/ax25/ax25_uid.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)


diff --git a/net/ax25/ax25_uid.c b/net/ax25/ax25_uid.c
index 57aeba7..d5cfbcf 100644
--- a/net/ax25/ax25_uid.c
+++ b/net/ax25/ax25_uid.c
@@ -148,9 +148,13 @@ static void *ax25_uid_seq_start(struct seq_file *seq, loff_t *pos)
 {
 	struct ax25_uid_assoc *pt;
 	struct hlist_node *node;
-	int i = 0;
+	int i = 1;
 
 	read_lock(&ax25_uid_lock);
+	
+	if (*pos == 0)
+		return SEQ_START_TOKEN;
+
 	ax25_uid_for_each(pt, node, &ax25_uid_list) {
 		if (i == *pos)
 			return pt;
@@ -162,8 +166,10 @@ static void *ax25_uid_seq_start(struct seq_file *seq, loff_t *pos)
 static void *ax25_uid_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	++*pos;
-
-	return hlist_entry(((ax25_uid_assoc *)v)->uid_node.next,
+	if (v == SEQ_START_TOKEN)
+		return ax25_uid_list.first;
+	else
+		return hlist_entry(((ax25_uid_assoc *)v)->uid_node.next,
 			   ax25_uid_assoc, uid_node);
 }
 

