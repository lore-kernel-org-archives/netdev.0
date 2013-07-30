From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH RFC] xfrm{4,6}: only report errors back to local sockets
 if we don't cross address family
Date: Tue, 30 Jul 2013 10:21:18 +0200
Message-ID: <20130730082118.GA25511@secunet.com>
References: <20130729145017.GD2490@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, vi0oss@gmail.com,
	hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:58550 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754524Ab3G3IVU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jul 2013 04:21:20 -0400
Content-Disposition: inline
In-Reply-To: <20130729145017.GD2490@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 29, 2013 at 04:50:17PM +0200, Hannes Frederic Sowa wrote:
> xfrm6_local_error/xfrm4_tunnel_check_size report mtu errors back to a
> socket in case it is locally generated. If the packet first traversed
> a 6in4/4in6 tunnel before passing the xfrm layer, we could get a panic
> because of address family type mismatch in the error reporting functions.
> 

So the skb is still owned by a socket of the inner address family.
Is this intentional? Maybe the ndo_start_xmit() function of the
tunnel device should orphan the skb if we tunnel the packet
through a different address family.
