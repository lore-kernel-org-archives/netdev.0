From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] netpoll: protect napi_poll and poll_controller
 during dev_[open|close]
Date: Mon, 04 Feb 2013 21:06:42 -0500 (EST)
Message-ID: <20130204.210642.1455120579037699868.davem@davemloft.net>
References: <1359578665-29248-1-git-send-email-nhorman@tuxdriver.com>
	<1359999644-24872-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ivecera@redhat.com,
	bhutchings@solarflare.com, romieu@fr.zoreil.com,
	eric.dumazet@gmail.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47400 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753114Ab3BECGq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2013 21:06:46 -0500
In-Reply-To: <1359999644-24872-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Mon,  4 Feb 2013 12:40:44 -0500

> +	/*
> +	 * Block netpoll from trying to do any rx path servicing.
> +	 * If we don't do this there is a chance ndo_poll_controller
> +	 * or ndo_poll may be running while we open the device
> +	 */

Please format comments:

	/* Like
	 * this.
	 */

> +	/*
> +	 * Don't do any rx activity if the dev_lock mutex is held 
> +	 * the dev_open/close paths use this to block netpoll activity
> +	 * while changing device state
> +	 */

Same here.

> +int netpoll_rx_disable(struct net_device *dev)
> +{
> +        struct netpoll_info *ni;
> +	int idx;
> +        might_sleep();
> +        idx = srcu_read_lock(&netpoll_srcu);
> +        ni = srcu_dereference(dev->npinfo, &netpoll_srcu);

A lot of interesting indentation going on here.
