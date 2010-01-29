From: "Edgar E. Iglesias" <edgar.iglesias@gmail.com>
Subject: Re: [PATCH] skbuff: align sk_buff::cb to 64 bit
Date: Fri, 29 Jan 2010 23:54:04 +0100
Message-ID: <20100129225404.GA12440@laped.iglesias.mooo.com>
References: <4B635CA1.8070803@openwrt.org>
 <4B63643B.3070400@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Felix Fietkau <nbd@openwrt.org>, netdev@vger.kernel.org,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: David Daney <ddaney@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:14454 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755185Ab0A2WyJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2010 17:54:09 -0500
Received: by ey-out-2122.google.com with SMTP id d26so583445eyd.19
        for <netdev@vger.kernel.org>; Fri, 29 Jan 2010 14:54:07 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4B63643B.3070400@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 29, 2010 at 02:42:03PM -0800, David Daney wrote:
> Felix Fietkau wrote:
> > The alignment requirement for 64-bit load/store instructions on ARM is
> > implementation defined. Some CPUs (such as Marvell Feroceon) do not
> > generate an exception, if such an instruction is executed with an
> > address that is not 64 bit aligned. 
> > In such a case, the Feroceon corrupts adjacent memory, which showed up
> > in my tests as a crash in the rx path of ath9k that only occured with
> > CONFIG_XFRM set. This crash happened, because the first field of the
> > mac80211 rx status info in the cb is an u64, and changing it corrupted
> > the skb->sp field.
> > 
> > Signed-off-by: Felix Fietkau <nbd@openwrt.org>
> > Cc: stable@kernel.org
> > ---
> > --- a/include/linux/skbuff.h
> > +++ b/include/linux/skbuff.h
> > @@ -329,7 +329,7 @@ struct sk_buff {
> >  	 * want to keep them across layers you have to do a skb_clone()
> >  	 * first. This is owned by whoever has the skb queued ATM.
> >  	 */
> > -	char			cb[48];
> > +	char			cb[48] __attribute__((aligned(8)));
> >  
> 
> 
> s/__attribute__((aligned(8)))/__aligned(8)/
> 
> Could the same thing be achieved by swapping the order of the dev and 
> tstamp fields instead of adding the alignment attribute?
> 
> What is the sizeof(void *) on this thing?

I'd guess the problem is with the accessor to the thing.
something in the opaque cb ptr its beeing accessed wroingly causing
overwrites.

Cheers,
ed
