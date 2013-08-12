From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH RFC] xfrm{4,6}: only report errors back to local sockets
 if we don't cross address family
Date: Mon, 12 Aug 2013 07:54:14 +0200
Message-ID: <20130812055414.GK25511@secunet.com>
References: <20130729145017.GD2490@order.stressinduktion.org>
 <20130730082118.GA25511@secunet.com>
 <20130730083017.GA7068@order.stressinduktion.org>
 <20130730102611.GB25511@secunet.com>
 <20130801081150.GF3688@order.stressinduktion.org>
 <20130801100522.GC25511@secunet.com>
 <20130808224440.GJ14001@order.stressinduktion.org>
 <1376002677.4004.139.camel@edumazet-glaptop>
 <20130808230620.GK14001@order.stressinduktion.org>
 <20130810161629.GR14001@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	vi0oss@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:38909 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752994Ab3HLFyR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Aug 2013 01:54:17 -0400
Content-Disposition: inline
In-Reply-To: <20130810161629.GR14001@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 10, 2013 at 06:16:29PM +0200, Hannes Frederic Sowa wrote:
> 
> Seems skb->encapsulated helps, but I still have to wire it up for the ipv6
> tunnels.
> 
> I just prototyped this patch, but I fear I now introduced a dependency
> from core xfrm to ipv6, which I would like to have prevented (this would
> even happen if I put xfrm_local_error in a header file). Is this actually
> a problem? I fear so. The other way would be to put the local_error
> handler as function pointers somewhere reachable from struct sock.
> 

Maybe we should put a local_error() function pointer to struct
xfrm_state_afinfo and call it via inner_mode->afinfo->local_error().

This should always call the right local_error function and we
would not need to touch generic networking code to fix it.
