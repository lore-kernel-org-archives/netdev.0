From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: Avoid copying TCP packets unnecessarily
Date: Mon, 15 Oct 2007 01:47:28 -0700 (PDT)
Message-ID: <20071015.014728.78750651.davem@davemloft.net>
References: <20071014222037.7fa28640@inria.fr>
	<20071015045723.GA28388@gondor.apana.org.au>
	<20071015055457.GA28799@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: guichaz@yahoo.fr, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55040
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755463AbXJOIrY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 04:47:24 -0400
In-Reply-To: <20071015055457.GA28799@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 15 Oct 2007 13:54:57 +0800

> On Mon, Oct 15, 2007 at 12:57:23PM +0800, Herbert Xu wrote:
> > 
> > However, the fact that you're triggering this code at all tells
> > us that there is another bug further up the chain that's causing
> > us to generate partial checksums even though the NIC doesn't
> > support it.  Can you please give me the output of
> 
> Nevermind, tcp_fragment can generate such packets out of
> convenience.
> 
> Here's a little optimisation to avoid copying the packet in
> this case.
> 
> [NET]: Avoid copying TCP packets unnecessarily
> 
> TCP packets all have writable heads, that is, even though it's cloned, it is
> writable up to the end of the TCP header.  This patch makes skb_checksum_help
> aware of this fact by using skb_clone_writable and avoiding a copy for TCP.
> 
> I've also modified the BUG_ON tests to be unsigned.  The only case where this
> makes a difference is if csum_start points to a location before skb->data.
> Since skb->data should always include the header where the checksum field
> is (and all currently callers adhere to that), this change is safe and may
> uncover bugs later.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert!
