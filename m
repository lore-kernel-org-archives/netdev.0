From: Jon Hunter <jon-hunter@ti.com>
Subject: Re: [PATCH 1/5] ARM: OMAP2+: gpmc: Fix kernel BUG for DT boot mode
Date: Thu, 18 Oct 2012 13:46:18 -0500
Message-ID: <50804E7A.5050602@ti.com>
References: <cover.1350327320.git.richardcochran@gmail.com> <41d66042625157d089e9c9532030a6831e79c641.1350327324.git.richardcochran@gmail.com> <507DB9EC.9060407@ti.com> <79CD15C6BA57404B839C016229A409A83EB43B17@DBDE01.ent.ti.com> <5080315F.8090802@ti.com> <79CD15C6BA57404B839C016229A409A83EB43D0F@DBDE01.ent.ti.com> <50804AC7.3000309@ti.com> <79CD15C6BA57404B839C016229A409A83EB43DBA@DBDE01.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Mohammed, Afzal" <afzal@ti.com>,
	Russell King <linux@arm.linux.org.uk>,
	Arnd Bergmann <arnd@arndb.de>,
	Tony Lindgren <tony@atomide.com>,
	David Miller <davem@davemloft.net>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>
To: "Hiremath, Vaibhav" <hvaibhav@ti.com>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <79CD15C6BA57404B839C016229A409A83EB43DBA@DBDE01.ent.ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 10/18/2012 01:39 PM, Hiremath, Vaibhav wrote:
> On Fri, Oct 19, 2012 at 00:00:31, Hunter, Jon wrote:
>>
>> On 10/18/2012 01:04 PM, Hiremath, Vaibhav wrote:
>>> On Thu, Oct 18, 2012 at 22:12:07, Hunter, Jon wrote:
>>
>> ...
>>
>>>> Yes, but do you also see the bug that is hiding in gpmc_mem_init()?
>>>>
>>>> My point is to highlight this and not hide it, so that we can fix it
>>>> now. Otherwise if we wait until we enable the gpmc driver with DT and
>>>> this could hinder the DT migration later.
>>>>
>>>
>>> As I already mentioned in my previous response, your patch is required 
>>> irrespective of this patch. I would consider your patch as a cleanup patch.
>>>
>>>
>>> Both the patches are independent, your patch is handling the error path 
>>> properly, whereas, my patch makes sure that you don't unnecessarily probe 
>>> GPMC if you are booting from DT and GPMC node is not present, as described 
>>> above.
>>
>> Your patch hides a bug. That's my point. How do you expect am335x ever
>> to support gpmc devices if this bug is not addressed?
>>
> 
> Jon,
> May be my commit description was mis-leading to you.
> I am not commenting anything on your bug-fix, but do not agree that it is 
> anything to do with hiding a bug.

So we can agree is disagree on that ;-)

> I only agree with you on one point, if someone wants to change the board-
> file to use GPMC with DT boot mode, then he will not be able to use it.
> 
>> So I think that you are over-simplifying it when you say that my patch
>> is just a clean-up patch. I agree that it is adding appropriate error
>> handling, but it also highlights the presence of a bug by allowing the
>> probe to fail.
>>
>> Anyway, I don't care to debate this any further, 
> 
> Me neither...
> 
>> we just need to fix
>> gpmc_mem_init().
>>
> 
> Agreed, and that's what your patch rightly doing it.

No. My patch does not fix the _actual_ bug, it is still there. Why do
you think that the probe is still failing for am335x? Without fixing it
am335x will never be able to support gpmc. So gpmc_mem_init() still
needs to be fixed.

Jon
