From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: Re: [PATCH v2 1/3] net: irda: pxaficp_ir: use sched_clock() for time management
Date: Wed, 16 Sep 2015 11:34:01 +0200
Message-ID: <87eghyso6u.fsf@belgarion.home>
References: <1442058324-9760-1-git-send-email-robert.jarzmik@free.fr>
	<20150915.164025.1543038793305792029.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: samuel@sortiz.org, petr.cvek@tul.cz, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, arnd@arndb.de
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150915.164025.1543038793305792029.davem@davemloft.net> (David
	Miller's message of "Tue, 15 Sep 2015 16:40:25 -0700 (PDT)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: Robert Jarzmik <robert.jarzmik@free.fr>
> Date: Sat, 12 Sep 2015 13:45:22 +0200
>
>> Instead of using directly the OS timer through direct register access,
>> use the standard sched_clock(), which will end up in OSCR reading
>> anyway.
>> 
>> This is a first step for direct access register removal and machine
>> specific code removal from this driver.
>> 
>> Signed-off-by: Robert Jarzmik <robert.jarzmik@free.fr>
>
> What is the granularity of the OSCR register?
It's 307ns (ie. 3.25MHz clock).

> If it is not nanoseconds, then you need to adjust calculations
> such as this one:
Tell me if the 307ns requires something I should adjust.

My understanding is that the flow will be :
 sched_clock()
   rd->read_sched_clock() (cyc_to_ns() transformed for return)
     pxa_read_sched_clock()
       readl_relaxed(OSCR)

I didn't see any timings issue, as the flow looks equivalent to the readl(OSCR),
but I might have overlooked something.

Cheers.

-- 
Robert
