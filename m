From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: Re: [PATCH 2/3] net: irda: pxaficp_ir: convert to readl and writel
Date: Sat, 12 Sep 2015 13:03:45 +0200
Message-ID: <87d1xnucfi.fsf@belgarion.home>
References: <1441261251-19548-1-git-send-email-robert.jarzmik@free.fr>
	<1441261251-19548-3-git-send-email-robert.jarzmik@free.fr>
	<55EF43E9.2040000@tul.cz> <55EF8A0F.7070106@tul.cz>
	<87twr4un1h.fsf@belgarion.home> <55F11FDE.6050304@tul.cz>
	<87io7iv845.fsf@belgarion.home> <55F233D2.3020708@tul.cz>
	<87y4gdtr6e.fsf@belgarion.home> <55F3A798.5090904@tul.cz>
Mime-Version: 1.0
Content-Type: text/plain
Cc: zonque@gmail.com, ulf.hansson@linaro.org,
	Samuel Ortiz <samuel@sortiz.org>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>
To: Petr Cvek <petr.cvek@tul.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55F3A798.5090904@tul.cz> (Petr Cvek's message of "Sat, 12 Sep
	2015 06:18:32 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Petr Cvek <petr.cvek@tul.cz> writes:

>>>> And it is true I have not tested the rootfs special case, where drivers are not
>>>> yet initialized (and more specifically gpio and interrupt chip). Your backtrace
>>>> should tell me if you fall into this category of issues ... but I digress, this
>>>> has no link with pxaficp.
>>>
>>> Should I start new thread? (same bug can be present in the FICP too)
>> Yes, this pxamci bothers me, it deserves a thread.
>
> Will start soon.
And I think I see your problem now :
  (a) there is a regression from the commit 8c8fe97b2b8a, for which the fix is
  here: https://lkml.org/lkml/2015/9/6/112
  (b) for gpio expanders, another fix is here :
  https://lkml.org/lkml/2015/9/12/62

The regression is on dmaengine, that's where the thread belongs I think, at
least if that fixes your issue.

>>> but STIER is not just an offset, but full register address:
>>> 	
>>> 	__REG(0x40700004)
>>>
>>> So the definition should be changed, unless there is another patch I did not
>>> received (in that case, send me full patchset again please) :-).
>> Agreed, this is a bug in this patch. With this fix, is the pxaficp working or do
>> you need a bit more time to experiment ?
>
> I have tried with a nasty hack (use only lower part of address, it should equal with reg offset):
> 	#undef __REG
> 	-#define __REG(x) (x)
> 	+#define __REG(x) (x & 0xffff)
>
> and it seems to work. The module inits and I am able to see IrDA traffic and
> ping other machine. FIR mode (mostly impacted by DMA) is still untested as
> magician unfortunately supports only SIR mode.
Okay, I'll add a fix in the next iteration, thanks for finding this.

Cheers.

-- 
Robert
