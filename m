From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: per route MTU settings
Date: Wed, 16 Jan 2013 07:31:02 +0100
Message-ID: <20130116063101.GB18940@secunet.com>
References: <DUB107-W269A7F1946A7B27212F3F8ED2D0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pupilla@libero.it, netdev@vger.kernel.org
To: Lukas Tribus <luky-37@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:35161 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751590Ab3APGbF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2013 01:31:05 -0500
Content-Disposition: inline
In-Reply-To: <DUB107-W269A7F1946A7B27212F3F8ED2D0@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 15, 2013 at 06:07:59PM +0100, Lukas Tribus wrote:
> 
> Hi pupilla,
> 
> looks like the behavior changed with 3.2-rc5 and "[PATCH 5/5] ipv4:
> Don't use the cached pmtu informations for input routes" ([1], [2]).
> 
> Actually, a "mtu lock XYZ" applied to a route is a bit of a corner case.
> 
> 
> Steffen, you already made this statement once and I can only agree with you:
> 
> > The router that can't send the packet to the next hop network has to
> > send the ICMP Destination Unreachable message. We never propagated
> > learned PMTU informations and I would not like to change this
> 
> 
> But here is our issue:
> - the linux "ip_forwarder" has an MTU of 1500 Byte on relevant interfaces
> - there is a route with a "static" mtu lock at 1200 Byte
> - the box is supposed to forward a packet heading the 1200B MTU route
> 
> What happens is:
> - the packet is dropped (because it exceeds the 1200 Byte)
> - an ICMP Type 3 Code 4 message is generated with 576 Byte next-hop MTU
> 
> Notice that the 576 Byte indicated as next-hop MTU in the ICMP packet
> doesn't match neither outgoing interface MTU, nor the static route's MTU.
> 
> Prior to your patch (for example in 3.2-rc4), 1200 Byte was indicated as
> MTU in the ICMP packet.

This patch was needed during the times we cached the pmtu informations
on the inetpeer. Now the pmtu informations are back in the routes,
so this check is obsolete. We can simply revert it, I'll send a patch
to do that.
