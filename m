From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH v1 5/5] wave: Added basic version of TCP Wave
Date: Fri, 28 Jul 2017 18:51:18 -0700 (PDT)
Message-ID: <20170728.185118.436256421743075749.davem@davemloft.net>
References: <20170728195919.10099-1-natale.patriciello@gmail.com>
        <20170728195919.10099-6-natale.patriciello@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, netdev@vger.kernel.org, ahmed.said@uniroma2.it,
        zampognaro@ing.uniroma2.it, roseti@ing.uniroma2.it
To: natale.patriciello@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57552 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752860AbdG2BvU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 21:51:20 -0400
In-Reply-To: <20170728195919.10099-6-natale.patriciello@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Natale Patriciello <natale.patriciello@gmail.com>
Date: Fri, 28 Jul 2017 21:59:19 +0200

> +/* TCP Wave private struct */
> +struct wavetcp {
> +	/* The module flags */
> +	u8 flags;
> +	/* The current transmission timer (us) */
> +	u32 tx_timer;
> +	/* The current burst size (segments) */
> +	u16 burst;

This style of declaring a data structure wastes a lot of vertical
screen space.  Instead use:

	type	name;	/* comment */

> +static void wavetcp_init(struct sock *sk)
> +{
> +	struct tcp_sock *tp = tcp_sk(sk);
> +	struct wavetcp *ca = inet_csk_ca(sk);

Always declare local variables in longest to shortest line order.

> +	DBG("%u sport: %u [%s]\n", tcp_time_stamp, ca->sport,
> +	    __func__);

DO NOT define your own custom debug logging facilities.

The kernel has millions of mechanism by which you can log information
either in the kernel log buffer or in the kernel trace log.  THere is
everything from dynamic fine-grained run time enable/disable, to
compile time controls.

There is absolutely therefore never a reason to define custom
mechanisms like you are here.

Thanks.
