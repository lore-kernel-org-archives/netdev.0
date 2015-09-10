From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: Re: [PATCH 2/3] net: irda: pxaficp_ir: convert to readl and writel
Date: Thu, 10 Sep 2015 13:14:50 +0200
Message-ID: <87io7iv845.fsf@belgarion.home>
References: <1441261251-19548-1-git-send-email-robert.jarzmik@free.fr>
	<1441261251-19548-3-git-send-email-robert.jarzmik@free.fr>
	<55EF43E9.2040000@tul.cz> <55EF8A0F.7070106@tul.cz>
	<87twr4un1h.fsf@belgarion.home> <55F11FDE.6050304@tul.cz>
Mime-Version: 1.0
Content-Type: text/plain
Cc: zonque@gmail.com, ulf.hansson@linaro.org,
	Samuel Ortiz <samuel@sortiz.org>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>
To: Petr Cvek <petr.cvek@tul.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55F11FDE.6050304@tul.cz> (Petr Cvek's message of "Thu, 10 Sep
	2015 08:14:54 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Petr Cvek <petr.cvek@tul.cz> writes:

> Dne 9.9.2015 v 08:25 Robert Jarzmik napsal(a):
>> Petr Cvek <petr.cvek@tul.cz> writes:
>> 
>>> Dne 8.9.2015 v 22:24 Petr Cvek napsal(a):
>>>>
>>>> Did you defined resources somewhere? Actual resources are in
>>>> "pxa_ir_resources" variable at:
>> I have them in patch [1], which is exactly the patch you have made yourself.
>
> Is there a mailing list for this specific patch? It seems I did not get any
> mail with it.
Should have been posted to linux arm kernel mailing list, unless my mailer
failed ...

> BTW This patch required update of my kernel repo. It seems that my:
>
> 	magician.c patches + ficp patch + new dma engine
>
> does not work for me at all. Kernel throws some panic about interrupts and then
> it ends in an infinite stack dumping loop. Fault occurs before rootfs is
> mounted, so probably around MMC init (with removed SD card it fails normally
> with no rootfs found error).
Could you send me (privately) the stack you're getting please. This is something
I'd like to catch up early in the -rc releases.

> Is it required to change something in the mach-pxa machine specific files?
Nope. As long as CONFIG_PXA_DMA is set, it's alright. Building on top of
linux-next of the future v4.3-rc1 would be better, as the dmaengine support
should be consistent across drivers/dma and arch/arm/mach-pxa in there.

> Which hardware was used for testing new dma engine implementation? Notably MMC
> driver part, probably commit:
Mioa701 (pxa270), cm-x300 (pxa310), zylonite (pxa310). The MMC was specificaly
tested on mioa701, on top of linux-next a week ago (about the day v4.2 was released).

Now with your stack, could you also give me the upstream commit id of the tip of
the tree you're using (before your patches) please ?

And it is true I have not tested the rootfs special case, where drivers are not
yet initialized (and more specifically gpio and interrupt chip). Your backtrace
should tell me if you fall into this category of issues ... but I digress, this
has no link with pxaficp.

Cheers.

-- 
Robert
