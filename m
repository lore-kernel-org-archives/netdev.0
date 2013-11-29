From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: judge the accept_ra_defrtr before calling rt6_route_rcv
Date: Fri, 29 Nov 2013 07:09:45 +0100
Message-ID: <20131129060945.GJ24171@order.stressinduktion.org>
References: <529451F0.1060707@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:45866 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751296Ab3K2GJq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Nov 2013 01:09:46 -0500
Content-Disposition: inline
In-Reply-To: <529451F0.1060707@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 26, 2013 at 03:46:56PM +0800, Duan Jiong wrote:
> 
> when dealing with a RA message, if accept_ra_defrtr is false,
> the kernel will not add the default route, and then deal with
> the following route information options. Unfortunately, those
> options maybe contain default route, so let's judge the
> accept_ra_defrtr before calling rt6_route_rcv.
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>

I am ambivalent regarding this change.

accept_ra_defrtr protected against adding default routers without routing
options and accept_ra_rt_info_max_plen == -1 disables the acceptance of any
routing options in router advertisments.

I don't have an idea why we need this distinction altough I once used it for
testing. But because this change makes it more understandable for users I am
ok with that.

Greetings,

  Hannes
