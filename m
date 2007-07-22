From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH]: Resurrect napi_poll patch.
Date: Sun, 22 Jul 2007 17:51:52 +1000
Message-ID: <1185090712.6344.72.camel@localhost.localdomain>
References: <20070721.185905.18310463.davem@davemloft.net>
	 <1185071972.6344.61.camel@localhost.localdomain>
	 <20070721.205425.61337743.davem@davemloft.net>
	 <20070722.001818.82052713.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	jgarzik@pobox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:44206 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752889AbXGVHwU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Jul 2007 03:52:20 -0400
In-Reply-To: <20070722.001818.82052713.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2007-07-22 at 00:18 -0700, David Miller wrote:
> Rusty, how does it look otherwise?

I like it.  For a start, the simplification of the NAPI api was long
overdue, and the damage done by separating the napi_struct is really
minimal.  Overall the tg3 driver just looks a little nicer now, and
that's sweet.

Unfortunately my complete ignorance of netpoll prevents me from making
sensible comment there.  This seems to have slipped in tho:

> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -220,7 +220,8 @@ static RAW_NOTIFIER_HEAD(netdev_chain);
>   *	Device drivers call our routines to queue packets here. We empty the
>   *	queue in the local softnet handler.
>   */
> -DEFINE_PER_CPU(struct softnet_data, softnet_data) = { NULL };
> +
> +DEFINE_PER_CPU(struct softnet_data, softnet_data) = { NULL, };
>  
>  #ifdef CONFIG_SYSFS
>  extern int netdev_sysfs_init(void);

ISTR that noone is using buggy compilers which required per-cpu
initializations now, so this can simply be dropped.

(The new scheduler code doesn't initialize per-cpu, so if this is a
problem it should be noticed).

Thanks!
Rusty.


