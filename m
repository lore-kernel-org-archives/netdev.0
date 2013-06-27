From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RESEND] ipv6: add anti-spoofing checks for 6to4 and 6rd
Date: Thu, 27 Jun 2013 16:19:10 +0200
Message-ID: <20130627141910.GC18553@order.stressinduktion.org>
References: <20130123100248.GB7317@order.stressinduktion.org> <loom.20130627T154125-104@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Roman Mamedov <rm@romanrm.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:41526 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752067Ab3F0OTM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jun 2013 10:19:12 -0400
Content-Disposition: inline
In-Reply-To: <loom.20130627T154125-104@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 27, 2013 at 01:49:59PM +0000, Roman Mamedov wrote:
> Hannes Frederic Sowa <hannes <at> stressinduktion.org> writes:
> 
> > 
> > This patch adds anti-spoofing checks in sit.c as specified in RFC3964
> > section 5.2 for 6to4 and RFC5969 section 12 for 6rd. I left out the
> > checks which could easily be implemented with netfilter.
> > 
> > Specifically this patch adds following logic (based loosely on the
> > pseudocode in RFC3964 section 5.2):
> > 
> > if prefix (inner_src_v6) == rd6_prefix (2002::/16 is the default)
> >         and outer_src_v4 != embedded_ipv4 (inner_src_v6)
> >                 drop
> > if prefix (inner_dst_v6) == rd6_prefix (or 2002::/16 is the default)
> >         and outer_dst_v4 != embedded_ipv4 (inner_dst_v6)
> >                 drop
> > accept
> > 
> > To accomplish the specified security checks proposed by above RFCs,
> > it is still necessary to employ uRPF filters with netfilter. These new
> > checks only kick in if the employed addresses are within the 2002::/16 or
> > another range specified by the 6rd-prefix (which defaults to 2002::/16).
> 
> This broke access to all 6to4 destinations from any unrelated sit tunnels.
> 
> For example users of tunnelbroker.net IPv6 tunnel service (2001:470::/32)
> can no longer communicate with anyone using 6to4 anywhere on the internet.
> 
> In general, any host, routing to/from which happens to traverse a sit
> tunnel (using native IPv6 ranges), can no longer successfully send
> packets to a 6to4 destination.

Hmpf. :/

Indeed, I will revisit the patch. I had several test-cases with 6rd and 6to4
but tested static tunnel configs only once.

I'll try to provide a fix as soon as I am at home again.

Sorry and thanks for the report,

  Hannes
