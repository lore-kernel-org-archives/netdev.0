From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ethernet: mvneta: Support netpoll
Date: Tue, 29 Mar 2016 23:09:30 -0400 (EDT)
Message-ID: <20160329.230930.1234182429605936870.davem@davemloft.net>
References: <1459197678-12022-1-git-send-email-ezequiel@vanguardiasur.com.ar>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, netdev@vger.kernel.org
To: ezequiel@vanguardiasur.com.ar
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49285 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752895AbcC3DJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2016 23:09:34 -0400
In-Reply-To: <1459197678-12022-1-git-send-email-ezequiel@vanguardiasur.com.ar>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ezequiel Garcia <ezequiel@vanguardiasur.com.ar>
Date: Mon, 28 Mar 2016 17:41:18 -0300

> +/* Polled functionality used by netconsole and others in non interrupt mode */
> +static void mvneta_poll_controller(struct net_device *dev)
> +{
> +	struct mvneta_port *pp = netdev_priv(dev);
> +
> +	on_each_cpu(mvneta_percpu_poll_controller, pp, false);
> +}

This doesn't work.

netpoll may be invoked from any context whatsoever, even hardware
interrupt handlers or contexts where cpu interrupts are disabled.

smp_call_function() and thus on_each_cpu() may not be called with
disabled interrupts or from a hardware interrupt handler or from
a bottom half handler, all of which are valid situations where
netpoll may occur since printk's can occur anywhere.
