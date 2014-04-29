From: Patrick McHardy <kaber@trash.net>
Subject: Re: problem forwarding IP fragments with DF bit set (caused by ipv4:
 fix path MTU discovery with connection tracking)
Date: Tue, 29 Apr 2014 15:35:14 +0100
Message-ID: <20140429143512.GC12781@macbook.localnet>
References: <1398703056.12635.41.camel@sakura.staff.proxad.net>
 <1398707980.10880.6.camel@sakura.staff.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <edumazet@google.com>, davem@davemloft.net,
	netdev <netdev@vger.kernel.org>
To: Maxime Bizon <mbizon@freebox.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50267 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751778AbaD2Ofc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2014 10:35:32 -0400
Content-Disposition: inline
In-Reply-To: <1398707980.10880.6.camel@sakura.staff.proxad.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 28, 2014 at 07:59:40PM +0200, Maxime Bizon wrote:
> 
> On Mon, 2014-04-28 at 18:37 +0200, Maxime Bizon wrote:
> > 
> > conntrack causes the packets to be re-assembled, but since the
> > resulting skb now has IP_DF set, it fails the (DF + MTU) test in
> > ip_forward.c and causes ICMP frag_needed to be sent. 
> 
> hum isn't it just a matter of doing this ?

But why should we do this? The entire point of the patch was to fix PMTUD.

> --- a/net/ipv4/ip_fragment.c
> +++ b/net/ipv4/ip_fragment.c
> @@ -493,6 +493,8 @@ found:
>             skb->len + ihl > qp->q.max_size)
>                 qp->q.max_size = skb->len + ihl;
>  
> +       skb->local_df = 1;
> +
>         if (qp->q.last_in == (INET_FRAG_FIRST_IN | INET_FRAG_LAST_IN) &&
>             qp->q.meat == qp->q.len) {
>                 unsigned long orefdst = skb->_skb_refdst;
> 
> 
> -- 
> Maxime
> 
