From: Petr Cvek <petr.cvek@tul.cz>
Subject: Re: [PATCH 2/3] net: irda: pxaficp_ir: convert to readl and writel
Date: Fri, 11 Sep 2015 03:52:18 +0200
Message-ID: <55F233D2.3020708@tul.cz>
References: <1441261251-19548-1-git-send-email-robert.jarzmik@free.fr>
 <1441261251-19548-3-git-send-email-robert.jarzmik@free.fr>
 <55EF43E9.2040000@tul.cz> <55EF8A0F.7070106@tul.cz>
 <87twr4un1h.fsf@belgarion.home> <55F11FDE.6050304@tul.cz>
 <87io7iv845.fsf@belgarion.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Cc: zonque@gmail.com, ulf.hansson@linaro.org,
	Samuel Ortiz <samuel@sortiz.org>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>
To: Robert Jarzmik <robert.jarzmik@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bubo.tul.cz ([147.230.16.1]:53693 "EHLO bubo.tul.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751229AbbIKBr5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Sep 2015 21:47:57 -0400
In-Reply-To: <87io7iv845.fsf@belgarion.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dne 10.9.2015 v 13:14 Robert Jarzmik napsal(a):
> Petr Cvek <petr.cvek@tul.cz> writes:
> 
>> Dne 9.9.2015 v 08:25 Robert Jarzmik napsal(a):
>>> Petr Cvek <petr.cvek@tul.cz> writes:
>>>
>>>> Dne 8.9.2015 v 22:24 Petr Cvek napsal(a):
>>>>>
>>>>> Did you defined resources somewhere? Actual resources are in
>>>>> "pxa_ir_resources" variable at:
>>> I have them in patch [1], which is exactly the patch you have made yourself.
>>
>> Is there a mailing list for this specific patch? It seems I did not get any
>> mail with it.
> Should have been posted to linux arm kernel mailing list, unless my mailer
> failed ...
> 
Searching for:

	"ARM: pxa: add resources to pxaficp_ir"

did not found anything, same was for "ficp" in the linux-arm-kernel/netdev/linux-kernel
mailing list archive.

>> BTW This patch required update of my kernel repo. It seems that my:
>>
>> 	magician.c patches + ficp patch + new dma engine
>>
>> does not work for me at all. Kernel throws some panic about interrupts and then
>> it ends in an infinite stack dumping loop. Fault occurs before rootfs is
>> mounted, so probably around MMC init (with removed SD card it fails normally
>> with no rootfs found error).
> Could you send me (privately) the stack you're getting please. This is something
> I'd like to catch up early in the -rc releases.

Well this will be problem as I cannot save anything to an SD card after and during the failure.
Only viable interfaces would be earlycon on an infraport or high speed camera on LCD :-). 

But I was able to revert this commit:

	6464b71409511939efce1ae4fb4ec6e3483b11b2	mmc: pxamci: switch over to dmaengine use

and after that I am able to boot.

> 
> Now with your stack, could you also give me the upstream commit id of the tip of
> the tree you're using (before your patches) please ?

It is probably irelevant now, but for complete information:

Discovered on my working repo: mainline b8889c4fc6ba03e289cec6a4d692f6f080a55e53
Still present on fresh downloaded: linux-next 22dc312d56ba077db27a9798b340e7d161f1df05

> 
> And it is true I have not tested the rootfs special case, where drivers are not
> yet initialized (and more specifically gpio and interrupt chip). Your backtrace
> should tell me if you fall into this category of issues ... but I digress, this
> has no link with pxaficp.

Should I start new thread? (same bug can be present in the FICP too)

I will try to configure an initrd rootfs this should create more ways to save kernel log.


Anyway after mmc dma revert I was still not able to start FICP. There is an error:

	Unable to handle kernel paging request at virtual address 32e00004

from pxa_irda_startup() and it seems it is caused by register definitions. For example:

	writel_relaxed((val), (irda)->stuart_base + (off));

is called by

	stuart_writel(si, 0, STIER);

but STIER is not just an offset, but full register address:
	
	__REG(0x40700004)

So the definition should be changed, unless there is another patch I did not received (in that case, send me full patchset again please) :-).


Best regards,
Petr
