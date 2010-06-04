From: jamal <hadi@cyberus.ca>
Subject: [PATCH net-next-2.6] net: Remove unnecessary net action assertion
Date: Fri, 04 Jun 2010 08:06:22 -0400
Message-ID: <1275653182.3445.58.camel@bigi>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-NT6OaqziomdT1kYxwwdH"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:41160 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751850Ab0FDMG1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jun 2010 08:06:27 -0400
Received: by gye5 with SMTP id 5so788650gye.19
        for <netdev@vger.kernel.org>; Fri, 04 Jun 2010 05:06:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-NT6OaqziomdT1kYxwwdH
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

I will followup with another (independent) change on pedit.

cheers,
jamal

--=-NT6OaqziomdT1kYxwwdH
Content-Disposition: attachment; filename="act-nomunge"
Content-Type: text/plain; name="act-nomunge"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

commit 45c644796fe2aa834918b15d7b41e57ccf86c1b3
Author: Jamal Hadi Salim <hadi@cyberus.ca>
Date:   Fri Jun 4 06:16:30 2010 -0400

    net: Remove unnecessary net action assertion
    
    The extra assertion to allow packet munging only when there are
    no other ptypes listening which may have worked around an old bug
    is unnecessary. It is sufficient to check if the skb is cloned before
    trampling on it. Thanks to Herbert Xu for being persistent and patient
    in getting this across.
    [Note that cloning checks and assertions are the general rule used
    by tc actions (documentation/networking/tc-actions-env-rules.txt)].
    
    Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

diff --git a/net/core/dev.c b/net/core/dev.c
index ec01a59..b272752 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2662,9 +2662,6 @@ static inline struct sk_buff *handle_ing(struct sk_buff *skb,
 	if (*pt_prev) {
 		*ret = deliver_skb(skb, *pt_prev, orig_dev);
 		*pt_prev = NULL;
-	} else {
-		/* Huh? Why does turning on AF_PACKET affect this? */
-		skb->tc_verd = SET_TC_OK2MUNGE(skb->tc_verd);
 	}
 
 	switch (ing_filter(skb)) {

--=-NT6OaqziomdT1kYxwwdH--

