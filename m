From: Daniel Mack <zonque@gmail.com>
Subject: Re: [PATCH 1/2] net: davinci_mdio: enable and disable clock
Date: Thu, 02 Aug 2012 22:28:48 +0200
Message-ID: <501AE300.2090707@gmail.com>
References: <1343936616-29318-1-git-send-email-zonque@gmail.com> <alpine.DEB.2.00.1208021416550.18867@utopia.booyaka.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	koen@dominion.thruhere.net, mugunthanvnm@ti.com,
	linux-arm-kernel@lists.infradead.org
To: Paul Walmsley <paul@pwsan.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:38996 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753067Ab2HBU2x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2012 16:28:53 -0400
Received: by bkwj10 with SMTP id j10so4426737bkw.19
        for <netdev@vger.kernel.org>; Thu, 02 Aug 2012 13:28:51 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1208021416550.18867@utopia.booyaka.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02.08.2012 22:20, Paul Walmsley wrote:
> Hi
> 
> On Thu, 2 Aug 2012, Daniel Mack wrote:
> 
>> Make the driver control the device clocks. Appearantly, the Davinci
>> platform probes this driver with the clock all powered up, but on OMAP,
>> this isn't the case.
>>
>> Signed-off-by: Daniel Mack <zonque@gmail.com>
> 
>> ---
>>  drivers/net/ethernet/ti/davinci_mdio.c | 16 ++++++++++++++--
>>  1 file changed, 14 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
>> index cd7ee20..b4b6015 100644
>> --- a/drivers/net/ethernet/ti/davinci_mdio.c
>> +++ b/drivers/net/ethernet/ti/davinci_mdio.c
>> @@ -332,6 +332,8 @@ static int __devinit davinci_mdio_probe(struct platform_device *pdev)
>>  		goto bail_out;
>>  	}
>>  
>> +	clk_enable(data->clk);
>> +
> 
> This doesn't look right.  This clock should be enabled by the
> pm_runtime_get_sync() call just above this.  It shouldn't be necessary
> to enable it again unless something isn't right with the integration
> data. Likewise the pm_runtime_put_sync() calls should be superfluous.

Aah, thanks for the heads-up. To explain, I first worked with a dirty
hack to alias the clock, and I definitely needed these extra calls then.

> What hwmod data/device tree file are you using with this?

Later, I added the hwmod to move away from these hacks, and indeed, that
lets the pm runtime code handle the clock enabling. With that in place,
the patch we're talking about here is in fact unnecessary.

The second one though (the one that adds DT bindings) should go in.

I will send a separate one later that fixes the IS_ERR(data->clk) error
that Russell spotted. But that's now unrelated.


Thanks for the review,
Daniel
