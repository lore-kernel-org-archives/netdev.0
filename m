From: =?UTF-8?B?VGltbyBUZXLDpHM=?= <timo.teras@iki.fi>
Subject: Re: [RFC] SPD basic actions per netdev
Date: Thu, 01 Apr 2010 15:10:04 +0300
Message-ID: <4BB48D1C.80205@iki.fi>
References: <1270053478.26743.111.camel@bigi>	 <20100401003352.GA19147@gondor.apana.org.au>	 <1270089323.26743.138.camel@bigi>	 <20100401025247.GA19994@gondor.apana.org.au> <4BB42692.9010105@iki.fi>	 <20100401060145.GB20865@gondor.apana.org.au> <4BB43B38.1060004@iki.fi>	 <20100401062840.GA21284@gondor.apana.org.au> <4BB43DE6.9060300@iki.fi>	 <20100401063956.GA21422@gondor.apana.org.au>	 <1270121385.26743.169.camel@bigi>  <4BB487CA.3020603@iki.fi> <1270123246.26743.177.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:56033 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754108Ab0DAMKI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 08:10:08 -0400
Received: by ewy20 with SMTP id 20so318448ewy.1
        for <netdev@vger.kernel.org>; Thu, 01 Apr 2010 05:10:06 -0700 (PDT)
In-Reply-To: <1270123246.26743.177.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jamal wrote:
> On Thu, 2010-04-01 at 14:47 +0300, Timo Ter=C3=A4s wrote:
>=20
>> The thing is that currently FWD 'dev blah' matches the interface
>> to which the packet is being forwarded to. Someone might be using
>> this feature already.
>=20
> So this is the part i am missing i think. If i look at:
>=20
> int ip_forward(struct sk_buff *skb)
> {
> .....
>         if (!xfrm4_policy_check(NULL, XFRM_POLICY_FWD, skb))
>                 goto drop;
> ....
> ........later forwarding happens here ...
>         if (!xfrm4_route_forward(skb))
>                 goto drop;
> ...
> }
>=20
> On entry we have a legit skb->skb_iif.
> The validity check is before forwarding decision (where the interface
> the packet is being forwarded to is recognized).

On entry to ip_forward the routing decision has already been made.
Both oif and iif are valid on entry.

Currently policy_check() uses oif for SPD matching.

Do note that xfrm4_route_forward() is a no-op if there's no matching
policy. It has nothing to do with routing decision, it's purpose
is to wrap the dst_entry with xfrm_dst if the flow matches a valid
SPD.

>> Your patch changes semantics on how FWD policies are matched.
>=20
> I agree if what you say earlier is true.

