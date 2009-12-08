From: Joe Perches <joe@perches.com>
Subject: [PATCH 13/20] net/atm/pppoatm.c: checkpatch cleanups
Date: Mon,  7 Dec 2009 21:57:09 -0800
Message-ID: <6e41aa8bc3b58b1914cd835aa8a2f883bf2891d8.1260251570.git.joe@perches.com>
References: <cover.1260251570.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1045 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932631AbZLHF5O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2009 00:57:14 -0500
In-Reply-To: <cover.1260251570.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Includes some or all of these:

Mostly 80 column wrapped.
printk->pr_info and pr_cont
Use print_hex_dump
Use __func__ for embedded print strings
Move embedded assigns out of tests
Move trailing statements to new lines
switch/case cleanups
    removed breaks after returns
Removed paren around returns
Use %pM
Moved leading continuation logical tests to end of previous line

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/atm/pppoatm.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/atm/pppoatm.c b/net/atm/pppoatm.c
index 62db6d7..4008392 100644
--- a/net/atm/pppoatm.c
+++ b/net/atm/pppoatm.c
@@ -176,7 +176,8 @@ static void pppoatm_push(struct atm_vcc *atmvcc, struct sk_buff *skb)
 	}
 	ppp_input(&pvcc->chan, skb);
 	return;
-    error:
+
+error:
 	kfree_skb(skb);
 	ppp_input_error(&pvcc->chan, 0);
 }
@@ -209,7 +210,8 @@ static int pppoatm_send(struct ppp_channel *chan, struct sk_buff *skb)
 				goto nospace;
 			}
 			kfree_skb(skb);
-			if ((skb = n) == NULL)
+			skb = n;
+			if (skb == NULL)
 				return DROP_PACKET;
 		} else if (!atm_may_send(pvcc->atmvcc, skb->truesize))
 			goto nospace;
@@ -231,7 +233,7 @@ static int pppoatm_send(struct ppp_channel *chan, struct sk_buff *skb)
 		 skb, ATM_SKB(skb)->vcc, ATM_SKB(skb)->vcc->dev);
 	return ATM_SKB(skb)->vcc->send(ATM_SKB(skb)->vcc, skb)
 	    ? DROP_PACKET : 1;
-    nospace:
+nospace:
 	/*
 	 * We don't have space to send this SKB now, but we might have
 	 * already applied SC_COMP_PROT compression, so may need to undo
@@ -290,7 +292,8 @@ static int pppoatm_assign_vcc(struct atm_vcc *atmvcc, void __user *arg)
 	    (be.encaps == e_vc ? 0 : LLC_LEN);
 	pvcc->wakeup_tasklet = tasklet_proto;
 	pvcc->wakeup_tasklet.data = (unsigned long) &pvcc->chan;
-	if ((err = ppp_register_channel(&pvcc->chan)) != 0) {
+	err = ppp_register_channel(&pvcc->chan);
+	if (err != 0) {
 		kfree(pvcc);
 		return err;
 	}
-- 
1.6.6.rc0.57.gad7a

