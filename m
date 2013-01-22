From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 1/2] ipv4: Invalidate the socket cached route on pmtu
 events if possible
Date: Tue, 22 Jan 2013 11:04:10 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1301221059100.1675@ja.ssi.bg>
References: <20130121115911.GE30530@secunet.com> <alpine.LFD.2.00.1301212245170.1886@ja.ssi.bg> <20130122084223.GC9147@secunet.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	"Yurij M. Plotnikov" <Yurij.Plotnikov@oktetlabs.ru>,
	netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:36224 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752462Ab3AVJAp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2013 04:00:45 -0500
In-Reply-To: <20130122084223.GC9147@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 22 Jan 2013, Steffen Klassert wrote:

> > 	Another variant is to remember with flag 'new_rt'
> > that we should call __sk_dst_set, eg. when rt comes from
> > ip_route_output_flow. By this way we can avoid some of
> > the dst_hold/dst_release calls if sk_dst_cache is not
> > changed. IIRC, according to sk_dst_check, dst_check can
> > not return different dst from the ->check method.
> > 
> 
> With this variant, we also need to check the new_rt flag
> before we call the dst_release() function you mentioned
> above, right?

	Yes, also before the dst_release we add
after the first ip_route_output_flow.

> I think we should avoid refcounts whenever we can,
> so I prefer this variant. I'll do a patch.

	Yes, the flag is preferred because we should
keep sk_dst_cache until we decide to replace it with
__sk_dst_set.

Regards

--
Julian Anastasov <ja@ssi.bg>
