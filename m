From: jamal <hadi@cyberus.ca>
Subject: [PATCH net-next-2.6] net sched: make pedit check for clones instead
Date: Fri, 04 Jun 2010 08:43:06 -0400
Message-ID: <1275655386.3445.62.camel@bigi>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-1WkKpQoHsy/TaInedaie"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f187.google.com ([209.85.211.187]:37115 "EHLO
	mail-yw0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753357Ab0FDMun (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jun 2010 08:50:43 -0400
Received: by ywh17 with SMTP id 17so384836ywh.1
        for <netdev@vger.kernel.org>; Fri, 04 Jun 2010 05:50:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-1WkKpQoHsy/TaInedaie
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

And here's the second one. I noticed Changli's changes are not yet in
net-next. I will wait for that change to propagate and then send the
fix to pedit that i discussed with Herbert.

cheers,
jamal

--=-1WkKpQoHsy/TaInedaie
Content-Disposition: attachment; filename="pedit1"
Content-Type: text/plain; name="pedit1"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

commit 0697bf778d48d155ef48f652cee8f103db3dcedb
Author: Jamal Hadi Salim <hadi@cyberus.ca>
Date:   Fri Jun 4 08:39:47 2010 -0400

    net sched: make pedit check for clones instead
    
    Now that the core path doesnt set OK to munge we detect
    writable skbs by looking to see if they are cloned.
    
    Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index fdbd0b7..8d15caf 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -127,8 +127,7 @@ static int tcf_pedit(struct sk_buff *skb, struct tc_action *a,
 	int i, munged = 0;
 	u8 *pptr;
 
-	if (!(skb->tc_verd & TC_OK2MUNGE)) {
-		/* should we set skb->cloned? */
+	if (skb_cloned(skb)) {
 		if (pskb_expand_head(skb, 0, 0, GFP_ATOMIC)) {
 			return p->tcf_action;
 		}

--=-1WkKpQoHsy/TaInedaie--

