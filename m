From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Getting a NIC's MTU size
Date: Fri, 14 Feb 2014 17:52:22 +0100
Message-ID: <20140214165222.GC27343@order.stressinduktion.org>
References: <20140214150328.GB27343@order.stressinduktion.org> <20140214144412.GA27343@order.stressinduktion.org> <26474.1392388608@warthog.procyon.org.uk> <26769.1392390042@warthog.procyon.org.uk> <27696.1392392957@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:55322 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751053AbaBNQwX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 11:52:23 -0500
Content-Disposition: inline
In-Reply-To: <27696.1392392957@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 14, 2014 at 03:49:17PM +0000, David Howells wrote:
> 
> One further question:  If I want to get the MTU size of the NIC through which
> packets will go to get to a particular peer, can I do:
> 
> 	struct rtable *rt;
> 	struct flowi4 fl4;
> 	unsigned if_mtu;
> 
> 	rt = ip_route_output_ports(&init_net, &fl4, NULL,
> 				   peer->srx.transport.sin.sin_addr.s_addr, 0,
> 				   htons(7000), htons(7001),
> 				   IPPROTO_UDP, 0, 0);
> 
> 	if_mtu = rt->dst->dev->mtu;
> 
> 	dst_release(&rt->dst);
> 
> Or might this go wrong if rt->dst->dev changes under me?  Can it change
> without replacing the dst record?

If it is a one-shot query this is fine. If you store the dst somewhere you need
to check dst->obsolete flags and redo the lookup if it is > 0. ->dev pointer
won't change for a created dst.

Bye,

  Hannes
