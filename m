From: Patrick McHardy <kaber@trash.net>
Subject: Re: oops in net/ipv4/icmp.c:icmp_send() with icmp_errors_use_inbound_ifaddr
 (fwd)
Date: Mon, 21 May 2007 23:32:44 +0200
Message-ID: <46520FFC.5020804@trash.net>
References: <E1Hpdw3-0006CY-00@gondolin.me.apana.org.au> <4651CAA9.4050908@trash.net> <20070521212804.GB6234@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jmorris@namei.org, Curtis@greenkey.net,
	davem@davemloft.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64466 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754788AbXEUVcv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 May 2007 17:32:51 -0400
In-Reply-To: <20070521212804.GB6234@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Mon, May 21, 2007 at 06:36:57PM +0200, Patrick McHardy wrote:
> 
>>The IP stack shouldn't be too hard, we currently set skb->dev in
>>ip_output, after that we only have the POST_ROUTING hook and ip_fragment
>>which care. It wouldn't help with ipip/ip_gre though, at that point
>>skb->dev must point to the tunnel device.
> 
> 
> I think that should be OK though.  Once you pass through ipip/ip_gre's
> transmit function, you're conceptually a locally generated packet.


Yes, but it may generate ICMP errors for the original packet before
it has passed through it. The patch I sent earlier should also handle
this case correctly.

