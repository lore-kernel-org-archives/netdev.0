From: Joe Perches <joe@perches.com>
Subject: [PATCH 16/20] net/atm/raw.c: checkpatch cleanups
Date: Mon,  7 Dec 2009 21:57:12 -0800
Message-ID: <124f77d98fa3c027716cef9cf7f5296d2885bb60.1260251570.git.joe@perches.com>
References: <cover.1260251570.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1059 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932688AbZLHF5O (ORCPT <rfc822;netdev@vger.kernel.org>);
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
 net/atm/raw.c |   21 +++++++--------------
 1 files changed, 7 insertions(+), 14 deletions(-)

diff --git a/net/atm/raw.c b/net/atm/raw.c
index fb8a949..d0c4bd0 100644
--- a/net/atm/raw.c
+++ b/net/atm/raw.c
@@ -18,7 +18,7 @@
  * SKB == NULL indicates that the link is being closed
  */
 
-static void atm_push_raw(struct atm_vcc *vcc,struct sk_buff *skb)
+static void atm_push_raw(struct atm_vcc *vcc, struct sk_buff *skb)
 {
 	if (skb) {
 		struct sock *sk = sk_atm(vcc);
@@ -28,8 +28,7 @@ static void atm_push_raw(struct atm_vcc *vcc,struct sk_buff *skb)
 	}
 }
 
-
-static void atm_pop_raw(struct atm_vcc *vcc,struct sk_buff *skb)
+static void atm_pop_raw(struct atm_vcc *vcc, struct sk_buff *skb)
 {
 	struct sock *sk = sk_atm(vcc);
 
@@ -40,24 +39,22 @@ static void atm_pop_raw(struct atm_vcc *vcc,struct sk_buff *skb)
 	sk->sk_write_space(sk);
 }
 
-
-static int atm_send_aal0(struct atm_vcc *vcc,struct sk_buff *skb)
+static int atm_send_aal0(struct atm_vcc *vcc, struct sk_buff *skb)
 {
 	/*
 	 * Note that if vpi/vci are _ANY or _UNSPEC the below will
 	 * still work
 	 */
 	if (!capable(CAP_NET_ADMIN) &&
-	    (((u32 *) skb->data)[0] & (ATM_HDR_VPI_MASK | ATM_HDR_VCI_MASK)) !=
-	    ((vcc->vpi << ATM_HDR_VPI_SHIFT) | (vcc->vci << ATM_HDR_VCI_SHIFT)))
-	    {
+	    (((u32 *)skb->data)[0] & (ATM_HDR_VPI_MASK | ATM_HDR_VCI_MASK)) !=
+	    ((vcc->vpi << ATM_HDR_VPI_SHIFT) |
+	     (vcc->vci << ATM_HDR_VCI_SHIFT))) {
 		kfree_skb(skb);
 		return -EADDRNOTAVAIL;
 	}
-	return vcc->dev->ops->send(vcc,skb);
+	return vcc->dev->ops->send(vcc, skb);
 }
 
-
 int atm_init_aal0(struct atm_vcc *vcc)
 {
 	vcc->push = atm_push_raw;
@@ -67,7 +64,6 @@ int atm_init_aal0(struct atm_vcc *vcc)
 	return 0;
 }
 
-
 int atm_init_aal34(struct atm_vcc *vcc)
 {
 	vcc->push = atm_push_raw;
@@ -77,7 +73,6 @@ int atm_init_aal34(struct atm_vcc *vcc)
 	return 0;
 }
 
-
 int atm_init_aal5(struct atm_vcc *vcc)
 {
 	vcc->push = atm_push_raw;
@@ -86,6 +81,4 @@ int atm_init_aal5(struct atm_vcc *vcc)
 	vcc->send = vcc->dev->ops->send;
 	return 0;
 }
-
-
 EXPORT_SYMBOL(atm_init_aal5);
-- 
1.6.6.rc0.57.gad7a

