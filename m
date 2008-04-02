From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH][ICMP]: Dst entry leak in icmp_send host re-lookup code
 (v2).
Date: Thu, 3 Apr 2008 02:29:55 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.0804030136090.3169@u.domain.uli>
References: <47EA1694.1080208@openvz.org> <20080401121532.GA24470@gondor.apana.org.au>
 <Pine.LNX.4.58.0804021146500.29472@u.domain.uli> <20080402124024.GA9547@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	Pavel Emelyanov <xemul@openvz.org>,
	Denis Lunev <den@openvz.org>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([217.79.71.194]:54822 "EHLO u.domain.uli"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756752AbYDBXeF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Apr 2008 19:34:05 -0400
In-Reply-To: <20080402124024.GA9547@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Wed, 2 Apr 2008, Herbert Xu wrote:

> On Wed, Apr 02, 2008 at 12:19:06PM +0300, Julian Anastasov wrote:
> >
> > play with saddr=0. In my test setup with 2 interfaces ip_route_input
> > failed because I don't have route to the original destination
> > which is now provided as saddr to ip_route_input. No ICMP was sent
> > to sender while previous kernels send ICMP.
> 
> Yes this was an oversight.
> 
> [ICMP]: Ensure that ICMP relookup maintains status quo
> 
> The ICMP relookup path is only meant to modify behaviour when
> appropriate IPsec policies are in place and marked as requiring
> relookups.  It is certainly not meant to modify behaviour when
> IPsec policies don't exist at all.
> 
> However, due to an oversight on the error paths existing behaviour
> may in fact change should one of the relookup steps fail.
> 
> This patch corrects this by redirecting all errors on relookup
> failures to the previous code path.  That is, if the initial
> xfrm_lookup let the packet pass, we will stand by that decision
> should the relookup fail due to an error.

	I tested this fix and now ICMP error is sent correctly.
There is mistake in my previous email, I said there is no route but
I have route to my destination, only that ARP resolution fails (after
SNAT which makes the things more funny) and ICMP host unreachable
error should be sent. But it does not matter much, only that NAT
can confuse these xfrm calls but this is out of my knowledge.

Regards

--
Julian Anastasov <ja@ssi.bg>
