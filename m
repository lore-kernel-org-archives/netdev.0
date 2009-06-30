From: David Miller <davem@davemloft.net>
Subject: Re: forcedeth skb_gso_segment warning
Date: Mon, 29 Jun 2009 19:43:25 -0700 (PDT)
Message-ID: <20090629.194325.224550663.davem@davemloft.net>
References: <1244539163.4672.5.camel@johannes.local>
	<20090629040330.GA2981@gondor.apana.org.au>
	<20090629040641.GA3357@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55110
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753760AbZF3CnU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2009 22:43:20 -0400
In-Reply-To: <20090629040641.GA3357@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 29 Jun 2009 12:06:41 +0800

> On Mon, Jun 29, 2009 at 12:03:30PM +0800, Herbert Xu wrote:
>> 
>> tcp: Stop non-TSO packets morphing into TSO
> 
> Here's a follow-up patch to optimise this boundary case.
> 
> tcp: Do not tack on TSO data to non-TSO packet
> 
> If a socket starts out on a non-TSO route, and then switches to
> a TSO route, then we will tack on data to the tail of the tx queue
> even if it started out life as non-TSO.  This is suboptimal because
> all of it will then be copied and checksummed unnecessarily.
> 
> This patch fixes this by ensuring that skb->ip_summed is set to
> CHECKSUM_PARTIAL before appending extra data beyond the MSS.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
