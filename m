From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] netdev: re-expose net_device_stats to user headers
Date: Mon, 23 Aug 2010 16:43:23 +0100
Message-ID: <1282578203.2267.27.camel@achroite.uk.solarflarecom.com>
References: <20100823083258.0777e83d@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:18870 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754117Ab0HWPn1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 11:43:27 -0400
In-Reply-To: <20100823083258.0777e83d@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-08-23 at 08:32 -0700, Stephen Hemminger wrote:
> This commit broke iproute2 build:
> 
> commit be1f3c2c027cc5ad735df6a45a542ed1db7ec48b
> Author: Ben Hutchings <bhutchings@solarflare.com>
> Date:   Tue Jun 8 07:19:54 2010 +0000
> 
>     net: Enable 64-bit net device statistics on 32-bit architectures
>     
>     Use struct rtnl_link_stats64 as the statistics structure.
> 
> Iproute2 uses a the kernel exported headers, and the structure
> net_device_stats which is part of the netlink IFLA_STATS message
> was no longer exposed.
[...]

This is not true; the kernel uses struct rtnl_link_stats for IFLA_STATS.
AFAICS the only reference to struct net_device_stats in iproute2 is:

misc/ifstat.c:51:#define MAXS (sizeof(struct net_device_stats)/sizeof(unsigned long))

This should be changed to refer to the structure that is actually used.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

