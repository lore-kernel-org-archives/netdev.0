From: Patrick McHardy <kaber@trash.net>
Subject: [IPV6]: Uninline netfilter okfns
Date: Mon, 15 Oct 2007 10:30:19 +0200
Message-ID: <4713251B.4070208@trash.net>
References: <E1IbT8r-0000Av-00@gondolin.me.apana.org.au> <46FE6D73.4000002@trash.net> <20070929.171339.59681016.davem@davemloft.net> <20070930002601.GB7502@gondor.apana.org.au> <20070930004341.GA7769@gondor.apana.org.au> <46FFC2F4.8090602@trash.net> <20071014042604.GA11431@gondor.apana.org.au> <47131D64.3080008@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030202060704090705070002"
Cc: David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38500 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754657AbXJOIaW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 04:30:22 -0400
In-Reply-To: <47131D64.3080008@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030202060704090705070002
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Turns out IPv6 only has two functions which are marked inline
and where gcc is able to generate tail-calls, bridging doesn't
have a single one.


--------------030202060704090705070002
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[IPV6]: Uninline netfilter okfns

Uninline netfilter okfns for those cases where gcc can generate tail-calls.

Before:
   text    data     bss     dec     hex filename
8994153 1016524  524652 10535329         a0c1a1 vmlinux

After:
   text    data     bss     dec     hex filename
8992761 1016524  524652 10533937         a0bc31 vmlinux
-------------------------------------------------------
  -1392

All cases have been verified to generate tail-calls with and without netfilter.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 2a33a3e84be9c078de91ddf7496dbf026fe86ce2
tree e9401bf6eaafb1efeca6bb6f0e8ef013e1932513
parent 39533dafc9b0458fecebd2da36d682837c6ff9a2
author Patrick McHardy <kaber@trash.net> Mon, 15 Oct 2007 10:25:34 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 15 Oct 2007 10:25:34 +0200

 net/ipv6/ip6_input.c  |    2 +-
 net/ipv6/ip6_output.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index af355df..fac6f7f 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -149,7 +149,7 @@ out:
  */
 
 
-static inline int ip6_input_finish(struct sk_buff *skb)
+static int ip6_input_finish(struct sk_buff *skb)
 {
 	struct inet6_protocol *ipprot;
 	struct sock *raw_sk;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 011082e..13565df 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -70,7 +70,7 @@ static __inline__ void ipv6_select_ident(struct sk_buff *skb, struct frag_hdr *f
 	spin_unlock_bh(&ip6_id_lock);
 }
 
-static inline int ip6_output_finish(struct sk_buff *skb)
+static int ip6_output_finish(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb->dst;
 

--------------030202060704090705070002--
