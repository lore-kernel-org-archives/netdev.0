From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] rocker: fix a neigh entry leak issue
Date: Thu, 14 May 2015 22:26:24 -0400 (EDT)
Message-ID: <20150514.222624.838893967441144984.davem@davemloft.net>
References: <1431653605-11922-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, jiri@resnulli.us,
	sfeldma@gmail.com
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43983 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423217AbbEOC00 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 22:26:26 -0400
In-Reply-To: <1431653605-11922-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Fri, 15 May 2015 09:33:25 +0800

> Once we get a neighbour through looking up arp cache or creating a
> new one in rocker_port_ipv4_resolve(), the neighbour's refcount is
> already taken. But as we don't put the refcount again after it's
> used, this makes the neighbour entry leaked.
> 
> Suggested-by: Eric Dumazet <edumazet@google.com>
> Acked-by: Jiri Pirko <jiri@resnulli.us>
> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> ---
> v2:
>   Add the checking of return value of neigh_create() with IS_ERR()
>   to avoid another crash, which is suggested by Eric Dumazet.

Doesn't this leak exist in the 'net' tree?

If so, why are you targetting such a bug fix for 'net-next'?
