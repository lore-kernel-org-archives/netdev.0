From: Dave Kleikamp <shaggy@austin.ibm.com>
Subject: [PATCH] [IPSEC] Avoid null pointer dereference in xfrm4_rcv_encap
Date: Wed, 05 Apr 2006 09:59:38 -0500
Message-ID: <1144249178.10340.5.camel@kleikamp.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750855AbWDEO75@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm getting a panic that I've traced back to this changeset:
http://www.kernel.org/git/gitweb.cgi?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=e695633e21ffb6a443a8c2f8b3f095c7f1a48eb0

xfrm4_rcv_encap dereferences x->encap without testing it for null.

Signed-off-by: Dave Kleikamp <shaggy@austin.ibm.com>
--- linux-2.6.17-rc1-mm1/net/ipv4/xfrm4_input.c.orig	2006-04-04
07:37:23.444068000 -0500
+++ linux-2.6.17-rc1-mm1/net/ipv4/xfrm4_input.c	2006-04-05
09:01:08.798510500 -0500
@@ -90,7 +90,7 @@ int xfrm4_rcv_encap(struct sk_buff *skb,
 		if (unlikely(x->km.state != XFRM_STATE_VALID))
 			goto drop_unlock;
 
-		if (x->encap->encap_type != encap_type)
+		if (x->encap && (x->encap->encap_type != encap_type))
 			goto drop_unlock;
 
 		if (x->props.replay_window && xfrm_replay_check(x, seq))

-- 
David Kleikamp
IBM Linux Technology Center
