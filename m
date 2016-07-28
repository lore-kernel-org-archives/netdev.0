From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH RFC 0/1] xfrm: dst lookup doesn't account for fwmark
Date: Thu, 28 Jul 2016 07:20:13 +0200
Message-ID: <20160728052013.GK5710@gauss.secunet.com>
References: <CACwzwmXfY3rpWfaspveT3JvumhPXYrMCH3TUwM1WNgEFKZ_t4A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
To: Doug Applegate <doug.applegate@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:33985 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751361AbcG1FUS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jul 2016 01:20:18 -0400
Content-Disposition: inline
In-Reply-To: <CACwzwmXfY3rpWfaspveT3JvumhPXYrMCH3TUwM1WNgEFKZ_t4A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 22, 2016 at 03:50:30PM -0600, Doug Applegate wrote:
> I ran into an issue trying to route outgoing ipsec traffic from an
> ipsec responder hub that uses fwmark to route out a specific
> interface. The fwmark points to a route table that contains a default
> route out a specific interface.  The fwmark is applied based on
> incoming interface of incoming traffic. I noticed that the mark was
> not being used when doing a route lookup. Is there any reason why this
> is? If not does this patch look reasonable? I just followed similar
> logic to how TOS was being used before route-lookup. I've only tested
> on an earlier kernel (3.14) and it works. Thanks!
> 
> Here's an example:
> 
> The ipsec policy is simple, just a tunnel from 192.168.0.0/24 <-->
> 192.168.1.0/24 the ipsec hub is at 35.0.0.1 but when traffic is being
> responded too, instead of the expected interface (eth2) we end it out
> a different interface (eth0)
> 
> route table:
> # ip rule list
> 0: from all lookup local
> 32766: from all lookup main
> 32767: from all lookup default
> 40000: from all fwmark 0x2 lookup 3
> 40000: from all fwmark 0x4 lookup 4
> 50000: from all lookup 3
> 
> # ip route
> 25.0.0.0/30 dev eth0  src 25.0.0.1
> 35.0.0.0/30 dev eth2  src 35.0.0.1
> 192.168.1.0/24 dev lan1  src 192.168.1.1
> 
> # ip route list table 4
> default via 35.0.0.2 dev eth2 onlink
> # ip route list table 3
> default via 25.0.0.2 dev eth0 onlink

Can you provide some more information about your usecase?
Mapping between interfaces and IP addresses, policies
and states would be good.

Btw. why do you need to insert the routes as 'onlink'?
This disables some checks if this route is valid.
