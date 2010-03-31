From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/4] xfrm: remove policy lock when accessing	policy->walk.dead
Date: Wed, 31 Mar 2010 18:41:44 +0200
Message-ID: <4BB37B48.5020308@trash.net>
References: <1270030626-16687-1-git-send-email-timo.teras@iki.fi> <1270030626-16687-5-git-send-email-timo.teras@iki.fi> <20100331110345.GC12845@gondor.apana.org.au> <1270040773.26743.12.camel@bigi> <20100331131131.GA13793@gondor.apana.org.au> <1270042092.26743.26.camel@bigi> <20100331135331.GB14082@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, Timo Teras <timo.teras@iki.fi>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33153 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757772Ab0CaQlq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 12:41:46 -0400
In-Reply-To: <20100331135331.GB14082@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Wed, Mar 31, 2010 at 09:28:12AM -0400, jamal wrote:
>> -sudo ip route add 192.168.11.100 dev eth0 table 15
>> generates an event
>> -sudo ip route flush table 15
>> generates an event
>> -sudo ip route flush table 15
>> No event
> 
> That's completely different.  We don't have a route flush event,
> instead we're sending route delete events.  That's why when the
> table is empty you get no events.
> 
> If we had a route flush event then it would behave exactly the
> same.

I was just about to say the exact same thing when I noticed your
email. I agree with Herbert, the flush notification indicates that
the table is now empty, independant of its previous state.
