From: Patrick McHardy <kaber@trash.net>
Subject: [NET]: Fix kfree(skb)
Date: Tue, 27 Feb 2007 18:06:32 +0100
Message-ID: <45E46518.5070100@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080304050407060504010209"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	paul.moore@hp.com
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35884 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751900AbXB0RGe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Feb 2007 12:06:34 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080304050407060504010209
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit


--------------080304050407060504010209
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NET]: Fix kfree(skb)

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit ddab8d6f231e068c78fb6b1a987a576bc81363f9
tree f724269dd5ac7f125159614ce4482b1b98a5192f
parent 01363220f5d23ef68276db8974e46a502e43d01d
author Patrick McHardy <kaber@trash.net> Tue, 27 Feb 2007 18:02:52 +0100
committer Patrick McHardy <kaber@trash.net> Tue, 27 Feb 2007 18:02:52 +0100

 net/core/skbuff.c                 |    2 +-
 net/dccp/output.c                 |    2 +-
 net/netlabel/netlabel_unlabeled.c |    2 +-
 net/xfrm/xfrm_user.c              |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index f89ff15..820761f 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2037,7 +2037,7 @@ struct sk_buff *skb_segment(struct sk_bu
 err:
 	while ((skb = segs)) {
 		segs = skb->next;
-		kfree(skb);
+		kfree_skb(skb);
 	}
 	return ERR_PTR(err);
 }
diff --git a/net/dccp/output.c b/net/dccp/output.c
index f5c6aca..3282f2f 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -269,7 +269,7 @@ void dccp_write_xmit(struct sock *sk, in
 					 err);
 		} else {
 			dccp_pr_debug("packet discarded\n");
-			kfree(skb);
+			kfree_skb(skb);
 		}
 	}
 }
diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index 5bc3718..b931ede 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -173,7 +173,7 @@ static int netlbl_unlabel_list(struct sk
 	return 0;
 
 list_failure:
-	kfree(ans_skb);
+	kfree_skb(ans_skb);
 	return ret_val;
 }
 
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 2567453..3e66b55 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1401,7 +1401,7 @@ static int xfrm_get_ae(struct sk_buff *s
 
 	x = xfrm_state_lookup(&id->daddr, id->spi, id->proto, id->family);
 	if (x == NULL) {
-		kfree(r_skb);
+		kfree_skb(r_skb);
 		return -ESRCH;
 	}
 

--------------080304050407060504010209--
