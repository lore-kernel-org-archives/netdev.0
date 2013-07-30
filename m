From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC] xfrm{4,6}: only report errors back to local sockets if we don't cross address family
Date: Tue, 30 Jul 2013 10:30:17 +0200
Message-ID: <20130730083017.GA7068@order.stressinduktion.org>
References: <20130729145017.GD2490@order.stressinduktion.org> <20130730082118.GA25511@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, vi0oss@gmail.com
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:47895 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751363Ab3G3IaS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 04:30:18 -0400
Content-Disposition: inline
In-Reply-To: <20130730082118.GA25511@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 30, 2013 at 10:21:18AM +0200, Steffen Klassert wrote:
> On Mon, Jul 29, 2013 at 04:50:17PM +0200, Hannes Frederic Sowa wrote:
> > xfrm6_local_error/xfrm4_tunnel_check_size report mtu errors back to a
> > socket in case it is locally generated. If the packet first traversed
> > a 6in4/4in6 tunnel before passing the xfrm layer, we could get a panic
> > because of address family type mismatch in the error reporting functions.
> > 
> 
> So the skb is still owned by a socket of the inner address family.
> Is this intentional? Maybe the ndo_start_xmit() function of the
> tunnel device should orphan the skb if we tunnel the packet
> through a different address family.

I thought about this, too. But then we would stop accounting the data
to the socket while it is travelling the stack. I don't know about the
possible problems resulting from this.

Greetings,

  Hannes
