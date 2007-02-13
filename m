From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.20 crash in tcp_tso_segment()
Date: Tue, 13 Feb 2007 12:34:13 -0800 (PST)
Message-ID: <20070213.123413.35665346.davem@davemloft.net>
References: <E1HFc6X-0006n7-00@gondolin.me.apana.org.au>
	<45D1CC83.8080603@trash.net>
	<20070213175121.GA27281@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, maccetta@laurelnetworks.com,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52477
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751056AbXBMUeO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Feb 2007 15:34:14 -0500
In-Reply-To: <20070213175121.GA27281@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 14 Feb 2007 04:51:21 +1100

> On Tue, Feb 13, 2007 at 03:34:43PM +0100, Patrick McHardy wrote:
> >
> > The callpath shows the REJECT target sending a TCP reset.
> > I'm guessing it has something to do with skb_copy_expand
> > copying the gso fields.
> 
> Indeed.  We need to reset the GSO bits there since the new
> packet is nothing like the one it's copied from.
> 
> [NETFILTER]: Clear GSO bits for TCP reset packet
> 
> The TCP reset packet is copied from the original.  This
> includes all the GSO bits which do not apply to the new
> packet.  So we should clear those bits.
> 
> Spotted by Patrick McHardy.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Something like this is needed for all trees with GSO.
> Actually it applies to TSO too although the effect there
> is a bit harder to notice.

Applied, thanks Herbert.

I'll push this to -stable.

I'm kind of challenged for time as I'll be out of town from
Wednesday until Sunday, so if someone could cook up the TSO
variable of the patch for pre-GSO kernels I'd appreciate it.
