From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] SPD basic actions per netdev
Date: Thu, 01 Apr 2010 08:34:16 -0400
Message-ID: <1270125256.26743.195.camel@bigi>
References: <1270053478.26743.111.camel@bigi>
	 <20100401003352.GA19147@gondor.apana.org.au>
	 <1270089323.26743.138.camel@bigi>
	 <20100401025247.GA19994@gondor.apana.org.au> <4BB42692.9010105@iki.fi>
	 <20100401060145.GB20865@gondor.apana.org.au> <4BB43B38.1060004@iki.fi>
	 <20100401062840.GA21284@gondor.apana.org.au> <4BB43DE6.9060300@iki.fi>
	 <20100401063956.GA21422@gondor.apana.org.au>
	 <1270121385.26743.169.camel@bigi>  <4BB487CA.3020603@iki.fi>
	 <1270123246.26743.177.camel@bigi>  <4BB48D1C.80205@iki.fi>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Timo =?ISO-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.24]:25339 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752572Ab0DAMeW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 08:34:22 -0400
Received: by qw-out-2122.google.com with SMTP id 8so361090qwh.37
        for <netdev@vger.kernel.org>; Thu, 01 Apr 2010 05:34:21 -0700 (PDT)
In-Reply-To: <4BB48D1C.80205@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-04-01 at 15:10 +0300, Timo Ter=C3=A4s wrote:

> On entry to ip_forward the routing decision has already been made.
> Both oif and iif are valid on entry.

ah, ok - yes;->

> Currently policy_check() uses oif for SPD matching.

indeed it does.

So i can see the dilemma with fwd path. It would be nice
to be able to classify on both iif and oif.

So that leaves only IN direction. If i only worried about that
and use skb->skb_iif then at least i wont be breaking the semantics
for FWD/OUT (i.e the patch without check for FWD).=20

That would make semantics for selector ifindex as follows:
table    current    patch
----------------------------
OUT       fl->oif   fl->oif
=46WD       fl->oif   fl->oif
IN        N/A       skb->skb_iif

By "N/A" it means really you cant set it. If you do it doesnt work.

cheers,
jamal




