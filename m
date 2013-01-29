From: Stephen Boyd <sboyd@codeaurora.org>
Subject: Re: [PATCH] net: ks8851: convert to threaded IRQ
Date: Tue, 29 Jan 2013 11:21:56 -0800
Message-ID: <51082154.6010303@codeaurora.org>
References: <20130128.223157.1855971357181002973.davem@davemloft.net> <1359443790-8562-1-git-send-email-balbi@ti.com> <51081A94.1090202@codeaurora.org> <20130129190220.GA6223@arwen.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, mjr@cs.wisc.edu, netdev@vger.kernel.org
To: balbi@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:10734 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753500Ab3A2TV5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 14:21:57 -0500
In-Reply-To: <20130129190220.GA6223@arwen.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/29/13 11:02, Felipe Balbi wrote:
> On Tue, Jan 29, 2013 at 10:53:08AM -0800, Stephen Boyd wrote:
>> On 01/28/13 23:16, Felipe Balbi wrote:
>>> just as it should have been. It also helps
>>> removing the, now unnecessary, workqueue.
>> Tested-by: Stephen Boyd <sboyd@codeaurora.org>
>>
>>> Signed-off-by: Felipe Balbi <balbi@ti.com>
>>> ---
>>> @@ -1505,8 +1485,9 @@ static int ks8851_probe(struct spi_device *spi)
>>>  	ks8851_read_selftest(ks);
>>>  	ks8851_init_mac(ks);
>>>  
>>> -	ret = request_irq(spi->irq, ks8851_irq, IRQF_TRIGGER_LOW,
>>> -			  ndev->name, ks);
>>> +	ret = request_threaded_irq(spi->irq, NULL, ks8851_irq,
>>> +				   IRQF_TRIGGER_LOW | IRQF_ONESHOT,
>>> +				   ndev->name, ks);
>> I did notice one thing here. The name of the thread is irq/378-eth%d
>> (where 378 is the irq number). It seems that ndev->name is not fully
>> formed until register_netdev() is called and so when the thread is
>> created, the malformed name is used for the thread name.
> that would be a problem even before the conversion to threaded irq, the
> only difference is that 378- would be omitted.
>

It doesn't seem to be a problem in the non-threaded case presumably
because the name is pointed to directly, instead of being copied, for
the /proc/interrupts case. In other words, /proc/interrupts shows eth0
instead of eth%d with and without this patch applied.

-- 
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
hosted by The Linux Foundation
