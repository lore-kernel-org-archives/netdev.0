From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: Allow forwarding of ip_summed except CHECKSUM_COMPLETE
Date: Mon, 26 Mar 2007 23:23:05 -0700 (PDT)
Message-ID: <20070326.232305.85395483.davem@davemloft.net>
References: <20070327053821.GA23596@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52712
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965028AbXC0GXG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 02:23:06 -0400
In-Reply-To: <20070327053821.GA23596@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 27 Mar 2007 15:38:21 +1000

> [NET]: Allow forwarding of ip_summed except CHECKSUM_COMPLETE
> 
> Right now Xen has a horrible hack that lets it forward packets with
> partial checksums.  One of the reasons that CHECKSUM_PARTIAL and
> CHECKSUM_COMPLETE were added is so that we can get rid of this hack
> (where it creates two extra bits in the skbuff to essentially mirror
> ip_summed without being destroyed by the forwarding code).
> 
> I had forgotten that I've already gone through all the deivce drivers
> last time around to make sure that they're looking at ip_summed ==
> CHECKSUM_PARTIAL rather than ip_summed != 0 on transmit.  In any case,
> I've now done that again so it should definitely be safe.
> 
> Unfortunately nobody has yet added any code to update CHECKSUM_COMPLETE
> values on forward so we I'm setting that to CHECKSUM_NONE.  This should
> be safe to remove for bridging but I'd like to check that code path
> first.
> 
> So here is the patch that lets us get rid of the hack by preserving
> ip_summed (mostly) on forwarded packets.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-2.6.22, thanks Herbert.
