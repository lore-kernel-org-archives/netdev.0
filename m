From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/1] ipv6 addrconf:fix preferred lifetime state-changing
 behavior while valid_lft is infinity
Date: Thu, 12 Dec 2013 18:06:56 +0400
Message-ID: <52A9C300.2050403@cogentembedded.com>
References: <20131212010348.GD4675@order.stressinduktion.org> <1386843347-2725-1-git-send-email-yazzep@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Yasushi Asano <yasushi.asano@jp.fujitsu.com>
To: yazzep@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:47741 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751503Ab3LLOGy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 09:06:54 -0500
Received: by mail-la0-f54.google.com with SMTP id b8so348950lan.13
        for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 06:06:52 -0800 (PST)
In-Reply-To: <1386843347-2725-1-git-send-email-yazzep@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12-12-2013 14:15, yazzep@gmail.com wrote:

> From: Yasushi Asano <yasushi.asano@jp.fujitsu.com>

>   Fixed a problem with setting the lifetime of an IPv6
>   address. When setting preferred_lft to a value not zero or
>   infinity, while valid_lft is infinity(0xffffffff) preferred
>   lifetime is set to forever and does not update. Therefore
>   preferred lifetime never becomes deprecated. valid lifetime
>   and preferred lifetime should be set independently, even if
>   valid lifetime is infinity, preferred lifetime must expire
>   correctly (meaning it must eventually become deprecated)


> Signed-off-by: Yasushi Asano <yasushi.asano@jp.fujitsu.com>
> ---
>   net/ipv6/addrconf.c |   34 ++++++++++++++++++++--------------
>   1 files changed, 20 insertions(+), 14 deletions(-)

> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 3c3425e..17b4097 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -948,18 +948,22 @@ static void ipv6_del_addr(struct inet6_ifaddr *ifp)
[...]
> +					if (ifp->valid_lft !=
> +						INFINITY_LIFE_TIME) {

    Please start the continuation line right under 'ifp', according to the 
networking coding style -- this ways it's easier on the eyes and don't mix 
with the following block.

> +						spin_lock(&ifa->lock);
> +
> +						lifetime = addrconf_timeout_fixup(
> +								ifa->valid_lft,	HZ);
> +						/*
> +						 * Note: Because this address is

    s/Because/because/, so that the grammar is correct.

> +						 * not permanent, lifetime <
> +						 * LONG_MAX / HZ here.
> +						 */

    Networking code assumes slightly other style of multi-line comments:

/* bla
  * bla
  */

WBR, Sergei
