From: Patrick McHardy <kaber@trash.net>
Subject: Re: IPsec PMTUD problem
Date: Tue, 03 Apr 2007 18:32:07 +0200
Message-ID: <46128187.4090601@trash.net>
References: <46110ED1.9070209@trash.net> <20070403095510.GA7754@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38270 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933636AbXDCQcK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2007 12:32:10 -0400
In-Reply-To: <20070403095510.GA7754@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Mon, Apr 02, 2007 at 04:10:25PM +0200, Patrick McHardy wrote:
> 
>>I noticed a problem with PMTUD between two IPsec tunnel endpoints.
>>When sending a packet larger than the PMTU with IP_DF from one
>>tunnel endpoint to the other, xfrm4_output sends an ICMP frag.
>>required with the IPsec MTU. Since the addresses match the tunnel
>>endpoints, this updates the MTU for the XFRM route with the value
>>that was calculated for the entire bundle, which in turn causes
>>a decrease for the bundle, resulting in further ICMP frag. required
>>messages until the minimum is reached.
> 
> 
> I presume you're using the same pair of addresses inside and
> outside the tunnel? If so the problem is that the kernel doesn't
> distinguish between internal ICMP errors and external ones.
> So when an MTU update occurs for the internal pair the external
> pair is also affected.

Exactly.

> We'd need some field in the routing cache to distinguish the
> two pairs.

I'm not sure I understand how this would work, the ICMP message
looks the same in both cases. Or are you suggesting to
differentiate based on the source of the ICMP message?

> Of course the easy work-around is to use distinct addresses
> within IPsec tunnels.

Yes, that would work as a workaround, but it still seems like
something worth fixing.

