From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [IPv6] interface-local multicast escapes the local node
Date: Thu, 7 Feb 2013 02:00:10 +0100
Message-ID: <20130207010010.GD19537@order.stressinduktion.org>
References: <20130206084949.GA11193@eerihug-hybrid.ki.sw.ericsson.se> <20130206121248.GC10290@order.stressinduktion.org> <20130206130739.GA1305@eerihug-hybrid.ki.sw.ericsson.se> <20130206134950.GD10290@order.stressinduktion.org> <51127781.2000504@linux-ipv6.org> <20130206160409.GB18040@order.stressinduktion.org> <51128985.2010701@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Erik Hugne <erik.hugne@ericsson.com>, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:48907 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752219Ab3BGBAL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 20:00:11 -0500
Content-Disposition: inline
In-Reply-To: <51128985.2010701@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 07, 2013 at 01:49:09AM +0900, YOSHIFUJI Hideaki wrote:
> >>
> >> NAK.
> >>
> >> Well, do you have relevant RFC?
> >> RFC4291 says that we should drop ff00::/16, but not ff01::/16.
> > 
> > I know what you mean, the RFC does not state it directly. Hm, the BSDs seem to
> > drop such destination addresses, too, if they don't originate from a loopback
> > interface. Or did you mean that there is a flaw in the skb->pkt_type !=
> > PACKET_LOOPBACK condition?
> 
> We do not drop ff01::/16, because RFC is silent about it.

I just did a little bit of research on this topic and found this:

RFC4541 3. IPv6 Considerations:

   MLD messages are also not sent regarding groups with addresses in the
   range FF00::/15 (which encompasses both the reserved FF00::/16 and
   node-local FF01::/16 IPv6 address spaces).  These addresses should
   never appear in packets on the link.

It gives a strong indication that we should drop these packets. What do you
think?

Thanks,

  Hannes
