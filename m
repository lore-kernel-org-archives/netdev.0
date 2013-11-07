From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: ipv6: a question about ECMP
Date: Thu, 7 Nov 2013 13:16:02 +0100
Message-ID: <20131107121602.GI8144@order.stressinduktion.org>
References: <527B6C70.3010507@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, nicolas.dichtel@6wind.com,
	netdev@vger.kernel.org
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:55414 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751753Ab3KGMQE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 07:16:04 -0500
Content-Disposition: inline
In-Reply-To: <527B6C70.3010507@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Duan!

On Thu, Nov 07, 2013 at 06:33:20PM +0800, Duan Jiong wrote:
>   After reading the ip6_pol_route(), i have a question about ECMP. Why we call
> the rt6_multipath_select() after calling rt6_select()?
>   In my opinion, the route returned by rt6_select() has a highest score, but the route
> returned by rt6_multipath_select() may has a lower score than the former, because the
> ECMP don't take the route preference into consideration. That means that the kernel will
> choose a less-desirable route.

ECMP routes only differ in the gateway the specify, so I doubt there will be
any change in the score they woud receive. rt6_multipath_select does merly
make sure we don't select the same route again and again.

Please note, the rt6_info's siblings fields were added for the solely purpose
of ECMP and the insertion only updates the siblings list if the above criteria
did hold. They make sure the routes lookup up do differ on each lookup, so it
does actually do multipath and does not depend on the order the routes where
inserted.

Hope that helps,

  Hannes
