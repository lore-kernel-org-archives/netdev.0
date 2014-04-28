From: Maxime Bizon <mbizon@freebox.fr>
Subject: Re: problem forwarding IP fragments with DF bit set (caused by
 ipv4: fix path MTU discovery with connection tracking)
Date: Mon, 28 Apr 2014 19:59:40 +0200
Message-ID: <1398707980.10880.6.camel@sakura.staff.proxad.net>
References: <1398703056.12635.41.camel@sakura.staff.proxad.net>
Reply-To: mbizon@freebox.fr
Mime-Version: 1.0
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, davem@davemloft.net,
	netdev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.iliad.fr ([212.27.33.1]:56837 "EHLO ns.iliad.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932272AbaD1TjS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2014 15:39:18 -0400
In-Reply-To: <1398703056.12635.41.camel@sakura.staff.proxad.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 2014-04-28 at 18:37 +0200, Maxime Bizon wrote:
> 
> conntrack causes the packets to be re-assembled, but since the
> resulting skb now has IP_DF set, it fails the (DF + MTU) test in
> ip_forward.c and causes ICMP frag_needed to be sent. 

hum isn't it just a matter of doing this ?

--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -493,6 +493,8 @@ found:
            skb->len + ihl > qp->q.max_size)
                qp->q.max_size = skb->len + ihl;
 
+       skb->local_df = 1;
+
        if (qp->q.last_in == (INET_FRAG_FIRST_IN | INET_FRAG_LAST_IN) &&
            qp->q.meat == qp->q.len) {
                unsigned long orefdst = skb->_skb_refdst;


-- 
Maxime
