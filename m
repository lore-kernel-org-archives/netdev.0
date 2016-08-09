From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dm9000: Fix irq trigger type setup on non-dt platforms
Date: Tue, 09 Aug 2016 15:08:46 -0700 (PDT)
Message-ID: <20160809.150846.2248066885154567471.davem@davemloft.net>
References: <1470758408-14248-1-git-send-email-s.nawrocki@samsung.com>
	<878tw5x3ir.fsf@belgarion.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: s.nawrocki@samsung.com, netdev@vger.kernel.org,
	linus.walleij@linaro.org, tglx@linutronix.de,
	b.zolnierkie@samsung.com, linux-kernel@vger.kernel.org,
	linux-samsung-soc@vger.kernel.org
To: robert.jarzmik@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35805 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932360AbcHIWIr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 18:08:47 -0400
In-Reply-To: <878tw5x3ir.fsf@belgarion.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Jarzmik <robert.jarzmik@free.fr>
Date: Tue, 09 Aug 2016 19:20:44 +0200

> Sylwester Nawrocki <s.nawrocki@samsung.com> writes:
> 
>> Commit b5a099c67a1c36b "net: ethernet: davicom: fix devicetree irq
>> resource" causes an interrupt storm after the ethernet interface
>> is activated on S3C24XX platform (ARM non-dt), due to the interrupt
>> trigger type not being set properly.
>>
>> It seems, after adding parsing of IRQ flags in commit 7085a7401ba54e92b
>> "drivers: platform: parse IRQ flags from resources", there is no path
>> for non-dt platforms where irq_set_type callback could be invoked when
>> we don't pass the trigger type flags to the request_irq() call.
>>
>> In case of a board where the regression is seen the interrupt trigger
>> type flags are passed through a platform device's resource and it is
>> not currently handled properly without passing the irq trigger type
>> flags to the request_irq() call.  In case of OF an of_irq_get() call
>> within platform_get_irq() function seems to be ensuring required irq_chip
>> setup, but there is no equivalent code for non OF/ACPI platforms.
>>
>> This patch mostly restores irq trigger type setting code which has been
>> removed in commit ("net: ethernet: davicom: fix devicetree irq resource").
>>
>> Fixes: b5a099c67a1c36b913 ("net: ethernet: davicom: fix devicetree irq resource")
>>
>> Signed-off-by: Sylwester Nawrocki <s.nawrocki@samsung.com>
>> ---
>>
>> Perhaps instead the core could be configuring the irqchip automatically as it
>> is done for OF/ACPI cases. I had doubts though if trying to make such changes
>> for a bug fix patch was the right thing to do.
> Hi Sylvester,
> 
> You're right, and I came to the same conclusion a bit earlier, in [1], but I
> didn't notice my FAI didn't actually send the mail. Your analysis of the core in
> non-OF/ACPI case is the reason I didn't post a patch for dm9000 ... I was
> overconfident in finding a reason in irq core code within a couple of days.
> 
> Therefore:
> Acked-by: Robert Jarzmik <robert.jarzmik@free.fr>

Applied.
