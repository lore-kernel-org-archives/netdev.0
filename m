From: Andi Kleen <ak@suse.de>
Subject: [PATCH] Eliminate some unnecessary gotos in tcp v4 hash handling
Date: Thu, 5 Apr 2007 12:48:44 +0200
Message-ID: <200704051248.44989.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:47608 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966086AbXDEKst (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Apr 2007 06:48:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The compiler eliminates them anyways and this makes the code easier to read
and shorter.

Signed-off-by: Andi Kleen <ak@suse.de>

Index: linux-2.6.21-rc3-net/net/ipv4/tcp_ipv4.c
===================================================================
--- linux-2.6.21-rc3-net.orig/net/ipv4/tcp_ipv4.c
+++ linux-2.6.21-rc3-net/net/ipv4/tcp_ipv4.c
@@ -2052,8 +2052,7 @@ static void *established_get_first(struc
 			if (sk->sk_family != st->family) {
 				continue;
 			}
-			rc = sk;
-			goto out;
+			return sk;
 		}
 		st->state = TCP_SEQ_STATE_TIME_WAIT;
 		inet_twsk_for_each(tw, node,
@@ -2061,13 +2060,11 @@ static void *established_get_first(struc
 			if (tw->tw_family != st->family) {
 				continue;
 			}
-			rc = tw;
-			goto out;
+			return tw;
 		}
 		read_unlock(&tcp_hashinfo.ehash[st->bucket].lock);
 		st->state = TCP_SEQ_STATE_ESTABLISHED;
 	}
-out:
 	return rc;
 }
 
@@ -2088,10 +2085,8 @@ get_tw:
 		while (tw && tw->tw_family != st->family) {
 			tw = tw_next(tw);
 		}
-		if (tw) {
-			cur = tw;
-			goto out;
-		}
+		if (tw)
+			return tw; 
 		read_unlock(&tcp_hashinfo.ehash[st->bucket].lock);
 		st->state = TCP_SEQ_STATE_ESTABLISHED;
 
@@ -2111,16 +2106,12 @@ get_tw:
 
 	sk_for_each_from(sk, node) {
 		if (sk->sk_family == st->family)
-			goto found;
+			return sk; 
 	}
 
 	st->state = TCP_SEQ_STATE_TIME_WAIT;
 	tw = tw_head(&tcp_hashinfo.ehash[st->bucket].twchain);
 	goto get_tw;
-found:
-	cur = sk;
-out:
-	return cur;
 }
 
 static void *established_get_idx(struct seq_file *seq, loff_t pos)
