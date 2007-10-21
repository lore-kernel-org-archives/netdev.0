From: jamal <hadi@cyberus.ca>
Subject: [PATCH 2/3] [NET_CLS_ACT] Use skb_act_clone
Date: Sun, 21 Oct 2007 15:20:20 -0400
Message-ID: <1192994420.4422.19.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-nCnwOcPDvXjSGd2q2TQa"
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.233]:9029 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751815AbXJUTUZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2007 15:20:25 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1132465wxd
        for <netdev@vger.kernel.org>; Sun, 21 Oct 2007 12:20:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-nCnwOcPDvXjSGd2q2TQa
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

A resubmit against net-2.6 from about an hour ago.

cheers,
jamal


--=-nCnwOcPDvXjSGd2q2TQa
Content-Disposition: attachment; filename=0002-NET_CLS_ACT-Use-skb_act_clone.txt
Content-Type: application/mbox; name=0002-NET_CLS_ACT-Use-skb_act_clone.txt
Content-Transfer-Encoding: 7bit

>From 92df260fb3e72cd7298a0994fa930a7af60ab3d0 Mon Sep 17 00:00:00 2001
From: Jamal Hadi Salim <hadi@cyberus.ca>
Date: Sun, 21 Oct 2007 15:02:41 -0400
Subject: [PATCH 2/3] [NET_CLS_ACT] Use skb_act_clone
clean skb_clone of any signs of CONFIG_NET_CLS_ACT and
have mirred us skb_act_clone()

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
---
 net/core/skbuff.c      |    7 -------
 net/sched/act_mirred.c |    2 +-
 2 files changed, 1 insertions(+), 8 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 70d9b5d..593a8da 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -415,13 +415,6 @@ static struct sk_buff *__skb_clone(struct sk_buff *n, struct sk_buff *skb)
 	n->hdr_len = skb->nohdr ? skb_headroom(skb) : skb->hdr_len;
 	n->nohdr = 0;
 	n->destructor = NULL;
-#ifdef CONFIG_NET_CLS_ACT
-	/* FIXME What is this and why don't we do it in copy_skb_header? */
-	n->tc_verd = SET_TC_VERD(n->tc_verd,0);
-	n->tc_verd = CLR_TC_OK2MUNGE(n->tc_verd);
-	n->tc_verd = CLR_TC_MUNGED(n->tc_verd);
-	C(iif);
-#endif
 	C(truesize);
 	atomic_set(&n->users, 1);
 	C(head);
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index fd7bca4..c3fde91 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -166,7 +166,7 @@ bad_mirred:
 		return TC_ACT_SHOT;
 	}
 
-	skb2 = skb_clone(skb, GFP_ATOMIC);
+	skb2 = skb_act_clone(skb, GFP_ATOMIC);
 	if (skb2 == NULL)
 		goto bad_mirred;
 	if (m->tcfm_eaction != TCA_EGRESS_MIRROR &&
-- 
1.4.4.1.gaed4


--=-nCnwOcPDvXjSGd2q2TQa--

