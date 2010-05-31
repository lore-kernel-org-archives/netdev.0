From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] ixp4xx: Support the all multicast flag on the NPE devices.
Date: Mon, 31 May 2010 18:23:37 +0200
Message-ID: <m3y6f0yr92.fsf@intrepid.localdomain>
References: <20100531131102.GA15870@riccoc20.at.omicron.at>
	<m3pr0c17ue.fsf@intrepid.localdomain>
	<20100531153419.GA17317@riccoc20.at.omicron.at>
	<19459.57149.428000.694558@pilspetsen.it.uu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Richard Cochran <richardcochran@gmail.com>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Mikael Pettersson <mikpe@it.uu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:43432 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751317Ab0EaQXk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 May 2010 12:23:40 -0400
In-Reply-To: <19459.57149.428000.694558@pilspetsen.it.uu.se> (Mikael
	Pettersson's message of "Mon, 31 May 2010 18:09:33 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mikael Pettersson <mikpe@it.uu.se> writes:

>  > +	static const u8 allmulti[] = { 0x01, 0x00, 0x00, 0x00, 0x00, 0x00 };
>  > +
>  > +	if (dev->flags & IFF_ALLMULTI) {
>  > +		for (i = 0; i < ETH_ALEN; i++) {
>  > +			__raw_writel(allmulti[i], &port->regs->mcast_addr[i]);
>  > +			__raw_writel(allmulti[i], &port->regs->mcast_mask[i]);
>
> Seems a bit excessive to define a lookup table for a computation
> that amounts to nothing more than "i ? 0 : 1".
>
> Something like the following would IMO be cleaner:
>
> 	if (...) {
> 		for (...) {
> 			u8 multi = i ? 0x00 : 0x01;
> 			__raw_writel(multi, ...);
> 			...
> 		}
> 	}

Well... cleaner = easier to understand?
I don't think so, the array is clearly a MAC address (mask) and the
"i ? 0x00 : 0x01" (which one could simply write as "!i") requires some
additional attention.

It's a slow "admin" path so an unmeasurable speedup doesn't mean
anything.
-- 
Krzysztof Halasa
