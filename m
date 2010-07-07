From: Karl Hiramoto <karl@hiramoto.org>
Subject: Re: [PATCH v2 1/9] atm: propagate signal changes via notifier
Date: Wed, 07 Jul 2010 09:40:37 +0200
Message-ID: <4C342F75.3000500@hiramoto.org>
References: <1278319561-23548-1-git-send-email-karl@hiramoto.org>	<1278319561-23548-2-git-send-email-karl@hiramoto.org> <20100706154158.542551c7@thirdoffive.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caiajhbdcbbj.dreamhost.com ([208.97.132.119]:56186 "EHLO
	homiemail-a33.g.dreamhost.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752490Ab0GGHkq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jul 2010 03:40:46 -0400
In-Reply-To: <20100706154158.542551c7@thirdoffive.cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  On 07/06/2010 09:41 PM, chas williams - CONTRACTOR wrote:
> On Mon,  5 Jul 2010 10:45:53 +0200
> Karl Hiramoto<karl@hiramoto.org>  wrote:
>
>> +void atm_dev_signal_change(struct atm_dev *dev, char signal)
>> +{
>> +	int i;
>> +	pr_debug("%s signal=%d dev=%p number=%d dev->signal=%d\n",
>> +		__func__, signal, dev, dev->number, dev->signal);
>> +
>> +	/* atm driver sending invalid signal */
>> +	WARN_ON(signal<  ATM_PHY_SIG_LOST || signal>
>> ATM_PHY_SIG_FOUND); +
>> +	if (dev->signal == signal)
>> +		return; /* no change */
>> +
>> +	dev->signal = signal;
>> +
>> +	&atm_dev_notify_chain, signal,
>> dev); +}
> i am not sure that you can use blocking_notifier_call_chain() here.
> atm_dev_signal_change() might be called from an interrupt context in
> some of the drivers.
>
> this implies that the notifier functions themselves must also not block.
> so in br2684 you probably want to use read_lock_irq() instead of just
> read_lock()

Chas,
I'll change to an atomic notifier, fix these issues, your other comments and send a new version of the patchset.

Thanks.

--
Karl
