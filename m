From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Improve handling of failures on link and route
 dumps
Date: Tue, 16 May 2017 14:54:36 -0400 (EDT)
Message-ID: <20170516.145436.967557028017706784.davem@davemloft.net>
References: <20170516061917.8128-1-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mq@ucw.cz
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52428 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752563AbdEPSyy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 14:54:54 -0400
In-Reply-To: <20170516061917.8128-1-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Mon, 15 May 2017 23:19:17 -0700

> In general, rtnetlink dumps do not anticipate failure to dump a single
> object (e.g., link or route) on a single pass. As both route and link
> objects have grown via more attributes, that is no longer a given.
> 
> netlink dumps can handle a failure if the dump function returns an
> error; specifically, netlink_dump adds the return code to the response
> if it is <= 0 so userspace is notified of the failure. The missing
> piece is the rtnetlink dump functions returning the error.
> 
> Fix route and link dump functions to return the errors if no object is
> added to an skb (detected by skb->len != 0). IPv6 route dumps
> (rt6_dump_route) already return the error; this patch updates IPv4 and
> link dumps. Other dump functions may need to be ajusted as well.
> 
> Reported-by: Jan Moskyto Matejka <mq@ucw.cz>
> Signed-off-by: David Ahern <dsahern@gmail.com>
> ---
> The recent IPv6 multipath change brought this to light because of the
> ease at which ipv6 route appends can exceed a buffer size, but it seems
> to be a day 1 problem.

Applied and queued up for -stable, thanks David.
