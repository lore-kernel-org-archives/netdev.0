From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH v2 1/9] atm: propagate signal changes via notifier
Date: Tue, 6 Jul 2010 15:41:58 -0400
Message-ID: <20100706154158.542551c7@thirdoffive.cmf.nrl.navy.mil>
References: <1278319561-23548-1-git-send-email-karl@hiramoto.org>
	<1278319561-23548-2-git-send-email-karl@hiramoto.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	nathan@traverse.com.au
To: Karl Hiramoto <karl@hiramoto.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:52405 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754776Ab0GFTmn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jul 2010 15:42:43 -0400
In-Reply-To: <1278319561-23548-2-git-send-email-karl@hiramoto.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  5 Jul 2010 10:45:53 +0200
Karl Hiramoto <karl@hiramoto.org> wrote:

> +void atm_dev_signal_change(struct atm_dev *dev, char signal)
> +{
> +	int i;
> +	pr_debug("%s signal=%d dev=%p number=%d dev->signal=%d\n",
> +		__func__, signal, dev, dev->number, dev->signal);
> +
> +	/* atm driver sending invalid signal */
> +	WARN_ON(signal < ATM_PHY_SIG_LOST || signal >
> ATM_PHY_SIG_FOUND); +
> +	if (dev->signal == signal)
> +		return; /* no change */
> +
> +	dev->signal = signal;
> +
> +	&atm_dev_notify_chain, signal,
> dev); +}

i am not sure that you can use blocking_notifier_call_chain() here.
atm_dev_signal_change() might be called from an interrupt context in
some of the drivers.

this implies that the notifier functions themselves must also not block.
so in br2684 you probably want to use read_lock_irq() instead of just
read_lock()
