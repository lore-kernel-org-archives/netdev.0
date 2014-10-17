From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ipv6: introduce tcp_v6_iif()
Date: Fri, 17 Oct 2014 09:52:38 -0700
Message-ID: <1413564758.24709.5.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1413562640.24953.26.camel@edumazet-glaptop2.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1C9D8C89@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:38742 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752638AbaJQQwk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2014 12:52:40 -0400
Received: by mail-pa0-f43.google.com with SMTP id lf10so1147003pab.16
        for <netdev@vger.kernel.org>; Fri, 17 Oct 2014 09:52:39 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1C9D8C89@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-10-17 at 16:26 +0000, David Laight wrote:
> From: Eric Dumazet
> > Commit 971f10eca186 ("tcp: better TCP_SKB_CB layout to reduce cache line
> > misses") added a regression for SO_BINDTODEVICE on IPv6.
> > 
> > This is because we still use inet6_iif() which expects that IP6 control
> > block is still at the beginning of skb->cb[]
> > 
> > This patch adds tcp_v6_iif() helper and uses it where necessary.
> > 
> > Because __inet6_lookup_skb() is used by TCP and DCCP, we add an iif
> > parameter to it.
> ...
> > diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> > index cf2e45ab2fa4..831495529b82 100644
> > --- a/net/ipv6/tcp_ipv6.c
> > +++ b/net/ipv6/tcp_ipv6.c
> > @@ -424,6 +424,7 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
> >  		if (sock_owned_by_user(sk))
> >  			goto out;
> > 
> > +		/* Note : We use inet6_iif() here, not tcp_v6_iif() */
> >  		req = inet6_csk_search_req(sk, &prev, th->dest, &hdr->daddr,
> >  					   &hdr->saddr, inet6_iif(skb));
> >  		if (!req)
> 
> That comment isn't particularly informative....

It is showing I considered this spot, and the right thing here is to use
inet6_iif()

The commit changelog will give to curious people the reasons.

Adding fat comments is superseded with good changelog.
