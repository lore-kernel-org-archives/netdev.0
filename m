From: Phil Oester <kernel@linuxace.com>
Subject: [PATCH] tcp: tcp_make_synack() should use sock_wmalloc
Date: Tue, 27 Aug 2013 16:41:40 -0700
Message-ID: <20130827234140.GA3301@linuxace.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="liOOAslEiF7prFVr"
Cc: eric.dumazet@gmail.com, pablo@netfilter.org
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--liOOAslEiF7prFVr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

In commit 90ba9b19 (tcp: tcp_make_synack() can use alloc_skb()), Eric changed
the call to sock_wmalloc in tcp_make_synack to alloc_skb.  In doing so,
the netfilter owner match lost its ability to block the SYNACK packet on
outbound listening sockets.  Revert the change, restoring the owner match
functionality.

This closes netfilter bugzilla #847.

Signed-off-by: Phil Oester <kernel@linuxace.com>


--liOOAslEiF7prFVr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=patch-tcp_make_synack

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 92fde8d..362c5f7 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2670,7 +2670,7 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	int tcp_header_size;
 	int mss;
 
-	skb = alloc_skb(MAX_TCP_HEADER + 15, sk_gfp_atomic(sk, GFP_ATOMIC));
+	skb = sock_wmalloc(sk, MAX_TCP_HEADER + 15, 1, GFP_ATOMIC);
 	if (unlikely(!skb)) {
 		dst_release(dst);
 		return NULL;

--liOOAslEiF7prFVr--
