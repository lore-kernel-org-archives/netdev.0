From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: unable to handle kernel paging request at 00000000d8be176d
Date: Fri, 06 Jul 2012 08:41:47 +0200
Message-ID: <1341556907.3265.93.camel@edumazet-glaptop>
References: <20120705134857.GA14643@localhost>
	 <20120705.142200.1828988382587831318.davem@davemloft.net>
	 <20120706055859.GA27693@localhost>
	 <1341555227.3265.54.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Fengguang Wu <wfg@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:54094 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751230Ab2GFGlw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 02:41:52 -0400
Received: by eeit10 with SMTP id t10so3477052eei.19
        for <netdev@vger.kernel.org>; Thu, 05 Jul 2012 23:41:51 -0700 (PDT)
In-Reply-To: <1341555227.3265.54.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-07-06 at 08:13 +0200, Eric Dumazet wrote:
> On Fri, 2012-07-06 at 13:58 +0800, Fengguang Wu wrote:
> > On Thu, Jul 05, 2012 at 02:22:00PM -0700, David Miller wrote:
> > > 
> > > Steffen Klassert posted a patch which fixes this.
> > 
> > Steffen's patch converts one oops message into another.
> > 
> > tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
> > head:   700db99d0140e9da2a31e08ebd3e1b121691aa26
> > commit: a2de86f63cfc92f7aaf11e7b9d9f2150946a1622 [1/2] ipv6: Initialize the neighbour pointer of rt6_info on allocation
> > 
> > x86_64-allyesdebian         BBB
> 
> Please try :
> 
> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> index 6d9c0ab..c6af596 100644
> --- a/net/ipv6/ip6_output.c
> +++ b/net/ipv6/ip6_output.c
> @@ -975,7 +975,7 @@ static int ip6_dst_lookup_tail(struct sock *sk,
>  	 * dst entry of the nexthop router
>  	 */
>  	rcu_read_lock();
> -	rt = (struct rt6_info *) dst;
> +	rt = (struct rt6_info *) *dst;
>  	n = rt->n;
>  	if (n && !(n->nud_state & NUD_VALID)) {
>  		struct inet6_ifaddr *ifp;
> 

David, what do you think if I submit a patch using following accessor ?

/* get a rt6_info given a dst_entry pointer */
static inline struct rt6_info *dst_rt6_info(struct dst_entry *dst)
{
	return (struct rt6_info *)dst;
}
