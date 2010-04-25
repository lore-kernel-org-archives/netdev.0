From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: PROBLEM: Linux kernel 2.6.31 IPv4 TCP fails to open huge amount of outgoing connections (unable to bind ... )
Date: Sun, 25 Apr 2010 19:56:00 +0400
Message-ID: <20100425155600.GA13319@ioremap.net>
References: <1271828799.7895.1287.camel@edumazet-laptop> <20100421082559.GA32475@ioremap.net> <1271840535.7895.1612.camel@edumazet-laptop> <20100421095812.GA14778@ioremap.net> <1271849253.7895.1929.camel@edumazet-laptop> <20100421182723.GA17202@ioremap.net> <1271875416.7895.3033.camel@edumazet-laptop> <20100421185837.GB21249@ioremap.net> <1271877975.7895.3171.camel@edumazet-laptop> <20100425142642.GA11411@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>,
	Gaspar Chilingarov <gasparch@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intermatrixgroup.ru ([195.178.208.66]:58157 "EHLO
	tservice.net.ru" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1752611Ab0DYP4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Apr 2010 11:56:07 -0400
Content-Disposition: inline
In-Reply-To: <20100425142642.GA11411@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 25, 2010 at 05:26:42PM +0300, Michael S. Tsirkin (mst@redhat.com) wrote:

> > diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
> > index 0c5e3c3..fb6959c 100644
> > --- a/net/ipv6/inet6_connection_sock.c
> > +++ b/net/ipv6/inet6_connection_sock.c
> > @@ -42,11 +42,16 @@ int inet6_csk_bind_conflict(const struct sock *sk,
> >  		if (sk != sk2 &&
> >  		    (!sk->sk_bound_dev_if ||
> >  		     !sk2->sk_bound_dev_if ||
> > -		     sk->sk_bound_dev_if == sk2->sk_bound_dev_if) &&
> > -		    (!sk->sk_reuse || !sk2->sk_reuse ||
> > -		     sk2->sk_state == TCP_LISTEN) &&
> > -		     ipv6_rcv_saddr_equal(sk, sk2))
> > -			break;
> > +		     sk->sk_bound_dev_if == sk2->sk_bound_dev_if)) {
> > +			if ((!sk->sk_reuse || !sk2->sk_reuse ||
> > +			     sk2->sk_state == TCP_LISTEN) &&
> > +			     ipv6_rcv_saddr_equal(sk, sk2))
> > +				break;
> > +			else if (sk->sk_reuse && sk2->sk_reuse &&
> > +				!ipv6_addr_any(inet6_rcv_saddr(sk2)) &&

I suppose above line is guilty when inet6_rcv_saddr() returns NULL?

-- 
	Evgeniy Polyakov
