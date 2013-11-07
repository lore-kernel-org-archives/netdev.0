From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: replace RTF_ROUTEINFO with RTF_ADDRCONF in  rt6_get_route_info()
Date: Thu, 7 Nov 2013 02:51:00 +0100
Message-ID: <20131107015100.GF8144@order.stressinduktion.org>
References: <5279EF31.4040705@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:54510 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751991Ab3KGBvC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 20:51:02 -0500
Content-Disposition: inline
In-Reply-To: <5279EF31.4040705@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 06, 2013 at 03:26:41PM +0800, Duan Jiong wrote:
> 
> As the rfc 4191 said, the Router Preference and Lifetime values in a
> ::/0 Route Information Option should override the preference and lifetime
> values in the Router Advertisement header. But when the kernel deals with
> a ::/0 Route Information Option, the rt6_get_route_info() always return
> NULL, that means that overriding will not happen, because those default
> routers were added without flag RTF_ROUTEINFO in rt6_add_dflt_router().
> 
> In order to match those default routers, we can replace RTF_ROUTEINFO 
> with RTF_ADDRCONF in rt6_get_route_info().
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>

Hmm, that looks like a bug. Nice catch!

Couldn't we just replace the rt6_get_route_info in rt6_route_rcv with a call
to rt6_get_dflt_router? Seems easier, already handles the ::/0 case and also
does preserve the check for the RTF_ROUTEINFO flag in rt6_add_route_info.

Greetings,

  Hannes
