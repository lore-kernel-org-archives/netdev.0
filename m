From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] SPD basic actions per netdev
Date: Thu, 01 Apr 2010 08:00:46 -0400
Message-ID: <1270123246.26743.177.camel@bigi>
References: <1270053478.26743.111.camel@bigi>
	 <20100401003352.GA19147@gondor.apana.org.au>
	 <1270089323.26743.138.camel@bigi>
	 <20100401025247.GA19994@gondor.apana.org.au> <4BB42692.9010105@iki.fi>
	 <20100401060145.GB20865@gondor.apana.org.au> <4BB43B38.1060004@iki.fi>
	 <20100401062840.GA21284@gondor.apana.org.au> <4BB43DE6.9060300@iki.fi>
	 <20100401063956.GA21422@gondor.apana.org.au>
	 <1270121385.26743.169.camel@bigi>  <4BB487CA.3020603@iki.fi>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Timo =?ISO-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.26]:57390 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755727Ab0DAMAv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 08:00:51 -0400
Received: by qw-out-2122.google.com with SMTP id 8so353942qwh.37
        for <netdev@vger.kernel.org>; Thu, 01 Apr 2010 05:00:50 -0700 (PDT)
In-Reply-To: <4BB487CA.3020603@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-04-01 at 14:47 +0300, Timo Ter=C3=A4s wrote:

>=20
> The thing is that currently FWD 'dev blah' matches the interface
> to which the packet is being forwarded to. Someone might be using
> this feature already.

So this is the part i am missing i think. If i look at:

int ip_forward(struct sk_buff *skb)
{
=2E....
        if (!xfrm4_policy_check(NULL, XFRM_POLICY_FWD, skb))
                goto drop;
=2E...
=2E.......later forwarding happens here ...
        if (!xfrm4_route_forward(skb))
                goto drop;
=2E..
}

On entry we have a legit skb->skb_iif.
The validity check is before forwarding decision (where the interface
the packet is being forwarded to is recognized).

> Your patch changes semantics on how FWD policies are matched.

I agree if what you say earlier is true.

cheers,
jamal

