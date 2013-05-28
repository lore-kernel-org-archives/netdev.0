From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next 1/3] ipv4: properly refresh rtable entries on
 pmtu/redirect events
Date: Tue, 28 May 2013 22:44:30 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1305282237020.1713@ja.ssi.bg>
References: <20130527.233844.2081972819091665848.davem@davemloft.net> <1369723593-5307-1-git-send-email-timo.teras@iki.fi> <alpine.LFD.2.00.1305281117190.1693@ja.ssi.bg> <20130528115357.4d9d281e@vostro>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:43806 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753578Ab3E1Tk7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 May 2013 15:40:59 -0400
In-Reply-To: <20130528115357.4d9d281e@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 28 May 2013, Timo Teras wrote:

> > > +static void fill_route_from_fnhe(struct rtable *rt, struct
> > > fib_nh_exception *fnhe) +{
> > > +	rt->rt_pmtu = fnhe->fnhe_pmtu;
> > > +	rt->dst.expires = fnhe->fnhe_expires;
> > 
> > 	The 'if (time_before' ... dst_set_expires() logic from
> > rt_bind_exception() is removed, may be it should be moved here,
> > i.e. fnhe_pmtu should be ignored if expired.
> 
> That code would not help much. The route's rt_pmtu is never reset to
> zero after the fnhe expires, so this would not make much difference.
> The old rt_pmtu and dst.expires would be left there anyway. All rt
> accesses check for expires too.

	I see, ipv4_mtu validates rt_pmtu expiration, so
such checks are not needed in rt_bind_exception and
fill_route_from_fnhe.

> This was actually intentional on the old code, as non-zero rt_pmtu
> implied that we had "next hop exception route" instead of "next hop
> route" and affected how the rt was invalidated in pmtu update.
> 
> If we want to clear out these fields, then it would make sense to have
> rt_bind_exception() to reset these on expiry to the struct
> fib_nh_exception directly and keep the direct assignments in
> fill_route_from_fnhe().
> 
> - Timo

Regards

--
Julian Anastasov <ja@ssi.bg>
