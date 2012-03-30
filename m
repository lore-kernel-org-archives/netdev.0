From: Igor Grinberg <grinberg@compulab.co.il>
Subject: Re: [PATCH 05/12] Add dummy smsc911x regulators to cm-t35.
Date: Fri, 30 Mar 2012 18:23:04 +0300
Message-ID: <4F75CFD8.7050809@compulab.co.il>
References: <1332494504-10251-1-git-send-email-Russ.Dill@ti.com> <1332494504-10251-6-git-send-email-Russ.Dill@ti.com> <4F71E290.2050403@compulab.co.il> <20120327172819.GQ9859@atomide.com> <4F72B0D0.70703@compulab.co.il> <20120328170316.GR9859@atomide.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Russ Dill <Russ.Dill@ti.com>, linux-omap@vger.kernel.org,
	Mark Brown <broonie@opensource.wolfsonmicro.com>,
	Matt Porter <mporter@ti.com>, robert.marklund@stericsson.com,
	linus.walleij@linaro.org,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Tony Lindgren <tony@atomide.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 50.23.254.54-static.reverse.softlayer.com ([50.23.254.54]:38251
	"EHLO softlayer.compulab.co.il" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752141Ab2C3PXY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Mar 2012 11:23:24 -0400
In-Reply-To: <20120328170316.GR9859@atomide.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/28/12 19:03, Tony Lindgren wrote:
> * Igor Grinberg <grinberg@compulab.co.il> [120327 23:36]:
>> Hi Tony,
>>
>> On 03/27/12 19:28, Tony Lindgren wrote:
>>> * Igor Grinberg <grinberg@compulab.co.il> [120327 08:56]:
>>>> Hi Russ,
>>>>
>>>> This patch works, but can we, please use the attached patch instead?
>>>
>>> Hmm what's the difference here? Do you have some real controllable
>>> regulator for one of the smsc911x instances?
>>
>> Well, the difference here is that those regulators will only be present
>> if the smsc911x controllers are present and their initialization is done
>> along with the controllers.
>> Also, I want to separate the cm-t35 from sb-t35 for future easier
>> refactoring of the sb-t35 code so it can be reused also on cm-t3517.
>>
>> Only vddvario for smsc911x.0 is controllable - connected to VIO, but
>> VIO will never be disabled as it also controls many other devices
>> (DRAM is among them), so I prefer it to be dummy and keep it together
>> with vdd33a.
> 
> OK thanks for the clarification. 
> 
>>> Anyways, I take it that you have tested that both smsc911x interfaces
>>> work now?
>>
>> Yes, both regulators are registered and found by the smsc911x driver.
>> There is some kind of problem with the smsc911x.1, but it looks unrelated
>> to the patch:
> 
> OK good to hear. Regarding the following problem..
>  
>> smsc911x: Driver version 2008-10-21
>> irq 323: nobody cared (try booting with the "irqpoll" option)
>> [<c001ae6c>] (unwind_backtrace+0x0/0xfc) from [<c0088960>] (__report_bad_irq+0x28/0xbc)
>> [<c0088960>] (__report_bad_irq+0x28/0xbc) from [<c0088bd4>] (note_interrupt+0x1e0/0x230)
>> [<c0088bd4>] (note_interrupt+0x1e0/0x230) from [<c0086e48>] (handle_irq_event_percpu+0xb0/0x1a0)
>> [<c0086e48>] (handle_irq_event_percpu+0xb0/0x1a0) from [<c0086f74>] (handle_irq_event+0x3c/0x5c)
>> [<c0086f74>] (handle_irq_event+0x3c/0x5c) from [<c00895a0>] (handle_level_irq+0x90/0xfc)
>> [<c00895a0>] (handle_level_irq+0x90/0xfc) from [<c008699c>] (generic_handle_irq+0x38/0x40)
>> [<c008699c>] (generic_handle_irq+0x38/0x40) from [<c02635a0>] (gpio_irq_handler+0x1b0/0x20c)
>> [<c02635a0>] (gpio_irq_handler+0x1b0/0x20c) from [<c008699c>] (generic_handle_irq+0x38/0x40)
>> [<c008699c>] (generic_handle_irq+0x38/0x40) from [<c0015404>] (handle_IRQ+0x38/0x84)
>> [<c0015404>] (handle_IRQ+0x38/0x84) from [<c000865c>] (omap3_intc_handle_irq+0x48/0x4c)
>> [<c000865c>] (omap3_intc_handle_irq+0x48/0x4c) from [<c00140c4>] (__irq_svc+0x44/0x78)
>> Exception stack(0xcf02de20 to 0xcf02de68)
>> de20: cf02c018 cf02c000 00000000 cf02de58 60000013 c06739fc 00000143 c06739fc
>> de40: 60000013 00000508 c06739dc 00000000 00022d69 cf02de68 cf02b3c0 c04890fc
>> de60: 20000013 ffffffff
>> [<c00140c4>] (__irq_svc+0x44/0x78) from [<c04890fc>] (_raw_spin_unlock_irqrestore+0x64/0x68)
>> [<c04890fc>] (_raw_spin_unlock_irqrestore+0x64/0x68) from [<c0087d50>] (__setup_irq+0x1b4/0x3d4)
>> [<c0087d50>] (__setup_irq+0x1b4/0x3d4) from [<c00881a0>] (request_threaded_irq+0xdc/0x148)
>> [<c00881a0>] (request_threaded_irq+0xdc/0x148) from [<c0482954>] (smsc911x_drv_probe+0x350/0x528)
>> [<c0482954>] (smsc911x_drv_probe+0x350/0x528) from [<c02d5a8c>] (platform_drv_probe+0x18/0x1c)
>> [<c02d5a8c>] (platform_drv_probe+0x18/0x1c) from [<c02d4580>] (really_probe+0x64/0x160)
>> [<c02d4580>] (really_probe+0x64/0x160) from [<c02d46c4>] (driver_probe_device+0x48/0x60)
>> [<c02d46c4>] (driver_probe_device+0x48/0x60) from [<c02d4770>] (__driver_attach+0x94/0x98)
>> [<c02d4770>] (__driver_attach+0x94/0x98) from [<c02d2ffc>] (bus_for_each_dev+0x54/0x80)
>> [<c02d2ffc>] (bus_for_each_dev+0x54/0x80) from [<c02d3730>] (bus_add_driver+0xa8/0x2a4)
>> [<c02d3730>] (bus_add_driver+0xa8/0x2a4) from [<c02d4d6c>] (driver_register+0x78/0x184)
>> [<c02d4d6c>] (driver_register+0x78/0x184) from [<c0008758>] (do_one_initcall+0x34/0x184)
>> [<c0008758>] (do_one_initcall+0x34/0x184) from [<c0613248>] (do_basic_setup+0x34/0x40)
>> [<c0613248>] (do_basic_setup+0x34/0x40) from [<c06132b8>] (kernel_init+0x64/0xec)
>> [<c06132b8>] (kernel_init+0x64/0xec) from [<c00154cc>] (kernel_thread_exit+0x0/0x8)
>> handlers:
>> [<c032ea98>] smsc911x_irqhandler
>> Disabling IRQ #323
>>
>> I still haven't had a chance to look into this.
>> Does anyone have a clue?
> 
> ..care to see if you have OMAP_GPIO_IRQ entry for your board? If so, we're
> still waiting for the cleanup-fixes branch to get merged that changes
> things to use gpio_to_irq() instead.

Nope, no OMAP_GPIO_IRQ in the board code.
Also, the GPIO -> IRQ mapping for the smsc911x is done in gpmc-smsc911x.c
and it uses gpio_to_irq() already.


-- 
Regards,
Igor.
