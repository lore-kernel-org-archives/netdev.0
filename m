From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 2/4] ipv4: Update pmtu informations on inetpeer only
 for output routes
Date: Tue, 15 Nov 2011 11:00:14 +0100
Message-ID: <20111115100014.GD20943@secunet.com>
References: <20111012.170805.2172804476308993385.davem@davemloft.net>
 <20111108.143630.106539981030509701.davem@davemloft.net>
 <20111114101244.GB20943@secunet.com>
 <20111114.143320.773675445837769668.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:60371 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754468Ab1KOKAQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Nov 2011 05:00:16 -0500
Content-Disposition: inline
In-Reply-To: <20111114.143320.773675445837769668.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 14, 2011 at 02:33:20PM -0500, David Miller wrote:
> From: Steffen Klassert <steffen.klassert@secunet.com>
> Date: Mon, 14 Nov 2011 11:12:44 +0100
> 
> > So for the moment I'm thinking about adding an ip_dst_mtu()
> > function that returns dst->ops->default_mtu() for input routes
> > and dst_mtu() for output routes. Then we could convert the
> > dst_mtu() users in net/ipv4/ over to this one.
> 
> We'll need something similar for ipv6 eventually...

Well, probaply. I did not test with ipv6 yet, so I focused to
fix the ipv4 part in the first place.

> 
> I would suggest that we do away with dst_ops->default_mtu() and just
> have dst_ops->mtu() which gets invoked unconditionally by dst_mtu().
> 
> You can integrate the ->default_mtu() handling and the input route
> check into this new method.  Then IPv6 can be fixed in a
> straightforward manner later.

Ok, I'll look into this. 
