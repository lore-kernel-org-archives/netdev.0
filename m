From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/3] net: irda: pxaficp_ir: use sched_clock() for
 time management
Date: Thu, 17 Sep 2015 14:51:06 -0700 (PDT)
Message-ID: <20150917.145106.1238429841434804906.davem@davemloft.net>
References: <1442058324-9760-1-git-send-email-robert.jarzmik@free.fr>
	<20150915.164025.1543038793305792029.davem@davemloft.net>
	<87eghyso6u.fsf@belgarion.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, petr.cvek@tul.cz, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, arnd@arndb.de
To: robert.jarzmik@free.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87eghyso6u.fsf@belgarion.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Robert Jarzmik <robert.jarzmik@free.fr>
Date: Wed, 16 Sep 2015 11:34:01 +0200

> David Miller <davem@davemloft.net> writes:
> 
>> From: Robert Jarzmik <robert.jarzmik@free.fr>
>> Date: Sat, 12 Sep 2015 13:45:22 +0200
>>
>>> Instead of using directly the OS timer through direct register access,
>>> use the standard sched_clock(), which will end up in OSCR reading
>>> anyway.
>>> 
>>> This is a first step for direct access register removal and machine
>>> specific code removal from this driver.
>>> 
>>> Signed-off-by: Robert Jarzmik <robert.jarzmik@free.fr>
>>
>> What is the granularity of the OSCR register?
> It's 307ns (ie. 3.25MHz clock).
> 
>> If it is not nanoseconds, then you need to adjust calculations
>> such as this one:
> Tell me if the 307ns requires something I should adjust.
> 
> My understanding is that the flow will be :
>  sched_clock()
>    rd->read_sched_clock() (cyc_to_ns() transformed for return)
>      pxa_read_sched_clock()
>        readl_relaxed(OSCR)
> 
> I didn't see any timings issue, as the flow looks equivalent to the readl(OSCR),
> but I might have overlooked something.

Of course it's different, because sched_clock() converts the value read
from OSCR into nanoseconds, which is obviously different from using the
OSCR register value directly.

You're therefore feeding different values into this IRDA code.
