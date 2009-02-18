From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFT 2/4] Add mod_timer_noact
Date: Wed, 18 Feb 2009 11:29:47 +0100
Message-ID: <499BE31B.5050808@trash.net>
References: <20090218051906.174295181@vyatta.com> <20090218052747.437271195@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Rick Jones <rick.jones2@hp.com>,
	Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, tglx@linutronix.de,
	Martin Josefsson <gandalf@wlug.westbo.se>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48543 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752378AbZBRK3u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 05:29:50 -0500
In-Reply-To: <20090218052747.437271195@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:

> +/***
> + * mod_timer_noact - modify a timer's timeout
> + * @timer: the timer to be modified
> + *
> + * mod_timer_noact works like mod_timer except that it doesn't activate an
> + * inactive timer, instead it returns without updating timer->expires.
> + *
> + * The function returns whether it has modified a pending timer or not.
> + * (ie. mod_timer_noact() of an inactive timer returns 0, mod_timer_noact() of
> + * an active timer returns 1.)
> + */
> +int mod_timer_noact(struct timer_list *timer, unsigned long expires)
> +{
> +	BUG_ON(!timer->function);
> +
> +	/*
> +	 * This is a common optimization triggered by the
> +	 * networking code - if the timer is re-modified
> +	 * to be the same thing then just return:
> +	 */
> +	if (timer->expires == expires && timer_pending(timer))
> +		return 1;

This doesn't seem right, since it uses TIMER_NOACT below, there's
no point in checking for timer_pending() I think.

> +
> +	return __mod_timer(timer, expires, TIMER_NOACT);
> +}
> +
> +EXPORT_SYMBOL(mod_timer_noact);
> +

