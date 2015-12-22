From: Huw Davies <huw@codeweavers.com>
Subject: Re: [RFC PATCH 16/17] calipso: Add validation of CALIPSO option.
Date: Tue, 22 Dec 2015 16:59:19 +0000
Message-ID: <20151222165919.GA31791@merlot>
References: <1450784813-18304-17-git-send-email-huw@codeweavers.com>
 <5679551C.4000105@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov, Paul Moore <pmoore@redhat.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.codeweavers.com ([216.251.189.131]:35402 "EHLO
	mail.codeweavers.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752515AbbLVQ73 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 11:59:29 -0500
Content-Disposition: inline
In-Reply-To: <5679551C.4000105@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 22, 2015 at 02:50:20PM +0100, Hannes Frederic Sowa wrote:
> On 22.12.2015 12:46, Huw Davies wrote:
> >  
> > +/* CALIPSO RFC 5570 */
> > +
> > +static bool ipv6_hop_calipso(struct sk_buff *skb, int optoff)
> > +{
> > +	const unsigned char *nh = skb_network_header(skb);
> > +
> > +	if (nh[optoff + 1] < 8)
> > +		goto drop;
> > +
> > +	if (nh[optoff + 6] * 4 + 8 > nh[optoff + 1])
> > +		goto drop;
> > +
> > +	if (!calipso_validate(skb, nh + optoff))
> > +		goto drop;
> > +
> > +	return true;
> > +
> > +drop:
> > +	kfree_skb(skb);
> > +	return false;
> > +}
> > +
> 
> Formally, if an extension header could not be processed, the packet
> should be discarded and an icmp error parameter extension should be
> send. I think we shouldn't let those packets pass here.

Thanks for your comments Hannes, I'm looking into your other
suggestions.

I'm confused about this one.  AFAICS, this will drop packets that we
can't process.  We don't send the icmp error, but I can certainly add
that.  Is that what you mean?

Thanks,
Huw.
