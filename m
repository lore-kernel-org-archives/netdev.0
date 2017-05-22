From: Blair Steven <blair.steven@alliedtelesis.co.nz>
Subject: [PATCH] Accept packets that the H.245 ALG can't process
Date: Mon, 22 May 2017 14:07:53 +1200
Message-ID: <20170522020753.16712-2-blair.steven@alliedtelesis.co.nz>
References: <20170522020753.16712-1-blair.steven@alliedtelesis.co.nz>
Cc: Blair Steven <blair.steven@alliedtelesis.co.nz>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:43340 "EHLO
        gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757008AbdEVCKZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 21 May 2017 22:10:25 -0400
Received: from mmarshal3.atlnz.lc (mmarshal3.atlnz.lc [10.32.18.43])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (Client did not present a certificate)
        by gate2.alliedtelesis.co.nz (Postfix) with ESMTPS id 6CDC88448C
        for <netdev@vger.kernel.org>; Mon, 22 May 2017 14:10:23 +1200 (NZST)
In-Reply-To: <20170522020753.16712-1-blair.steven@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When two VoIP end points are configured differently (fast connect /
not fast connect) the ALG was failing to find a matching expectation
and dropping packets in one direction.

Dropping packets not the job of an ALG, and as such the behaviour
has been changed to allow the packet to be send to the forwarding
engine.

Signed-off-by: Blair Steven <blair.steven@alliedtelesis.co.nz>
---
 net/netfilter/nf_conntrack_h323_main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_conntrack_h323_main.c
index 3bcdc71..6161375 100644
--- a/net/netfilter/nf_conntrack_h323_main.c
+++ b/net/netfilter/nf_conntrack_h323_main.c
@@ -625,7 +625,7 @@ static int h245_help(struct sk_buff *skb, unsigned int protoff,
       drop:
 	spin_unlock_bh(&nf_h323_lock);
 	nf_ct_helper_log(skb, ct, "cannot process H.245 message");
-	return NF_DROP;
+	return NF_ACCEPT;
 }
 
 /****************************************************************************/
@@ -1200,7 +1200,7 @@ static int q931_help(struct sk_buff *skb, unsigned int protoff,
       drop:
 	spin_unlock_bh(&nf_h323_lock);
 	nf_ct_helper_log(skb, ct, "cannot process Q.931 message");
-	return NF_DROP;
+	return NF_ACCEPT;
 }
 
 /****************************************************************************/
@@ -1785,7 +1785,7 @@ static int ras_help(struct sk_buff *skb, unsigned int protoff,
       drop:
 	spin_unlock_bh(&nf_h323_lock);
 	nf_ct_helper_log(skb, ct, "cannot process RAS message");
-	return NF_DROP;
+	return NF_ACCEPT;
 }
 
 /****************************************************************************/
-- 
2.9.3
