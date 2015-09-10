From: Petr Cvek <petr.cvek@tul.cz>
Subject: Re: [PATCH 2/3] net: irda: pxaficp_ir: convert to readl and writel
Date: Thu, 10 Sep 2015 08:14:54 +0200
Message-ID: <55F11FDE.6050304@tul.cz>
References: <1441261251-19548-1-git-send-email-robert.jarzmik@free.fr>
 <1441261251-19548-3-git-send-email-robert.jarzmik@free.fr>
 <55EF43E9.2040000@tul.cz> <55EF8A0F.7070106@tul.cz>
 <87twr4un1h.fsf@belgarion.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Cc: Samuel Ortiz <samuel@sortiz.org>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>
To: Robert Jarzmik <robert.jarzmik@free.fr>, zonque@gmail.com,
	ulf.hansson@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87twr4un1h.fsf@belgarion.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dne 9.9.2015 v 08:25 Robert Jarzmik napsal(a):
> Petr Cvek <petr.cvek@tul.cz> writes:
> 
>> Dne 8.9.2015 v 22:24 Petr Cvek napsal(a):
>>>
>>> Did you defined resources somewhere? Actual resources are in
>>> "pxa_ir_resources" variable at:
> I have them in patch [1], which is exactly the patch you have made yourself.

Is there a mailing list for this specific patch? It seems I did not get any mail with it.

> 
>> I tried to add following patch for new resources, but now it fails with:
>>
>> [  141.534545] pxa2xx-ir pxa2xx-ir: can't request region for resource [mem 0x40700000-0x40700100]
>> [  141.534574] pxa2xx-ir pxa2xx-ir: resource stuart not defined
>> [  141.534656] pxa2xx-ir: probe of pxa2xx-ir failed with error -16
>>
>> That's because STUART is allocated by normal UART driver at:
>>
>> 	http://lxr.free-electrons.com/source/arch/arm/mach-pxa/devices.c#L244
>>
>> So somehow there must be configuration for STUART used with FICP and STUART
>> alone (probably can be used for normal UART).
> That's because you have to remove from magician.c:
> 	pxa_set_stuart_info(NULL);
> 

Thanks, I missed that.

BTW This patch required update of my kernel repo. It seems that my:

	magician.c patches + ficp patch + new dma engine

does not work for me at all. Kernel throws some panic about interrupts and then it ends in an infinite stack dumping loop. Fault occurs before rootfs is mounted, so probably around MMC init (with removed SD card it fails normally with no rootfs found error).

Is it required to change something in the mach-pxa machine specific files?

Which hardware was used for testing new dma engine implementation? Notably MMC driver part, probably commit:

	6464b71409511939efce1ae4fb4ec6e3483b11b2

Best regards,
Petr
