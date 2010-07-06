From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH v2 1/9] atm: propagate signal changes via notifier
Date: Tue, 6 Jul 2010 15:29:50 -0400
Message-ID: <20100706152950.1ace642d@thirdoffive.cmf.nrl.navy.mil>
References: <1278319561-23548-1-git-send-email-karl@hiramoto.org>
	<1278319561-23548-2-git-send-email-karl@hiramoto.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	nathan@traverse.com.au
To: Karl Hiramoto <karl@hiramoto.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:56271 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753128Ab0GFTac (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jul 2010 15:30:32 -0400
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
> +	blocking_notifier_call_chain(&atm_dev_notify_chain, signal,
> dev); +}
> +EXPORT_SYMBOL(atm_dev_signal_change);


net/atm/common.c: In function 'atm_dev_signal_change':
net/atm/common.c:213: warning: unused variable 'i'

please remove i unless you need it
