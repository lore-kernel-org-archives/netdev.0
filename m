From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: Re: [PATCH v2 1/3] net: irda: pxaficp_ir: use sched_clock() for time management
Date: Fri, 18 Sep 2015 18:36:56 +0200
Message-ID: <87si6br8ev.fsf@belgarion.home>
References: <1442058324-9760-1-git-send-email-robert.jarzmik@free.fr>
	<20150915.164025.1543038793305792029.davem@davemloft.net>
	<87eghyso6u.fsf@belgarion.home>
	<20150917.145106.1238429841434804906.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: samuel@sortiz.org, petr.cvek@tul.cz, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, arnd@arndb.de
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150917.145106.1238429841434804906.davem@davemloft.net> (David
	Miller's message of "Thu, 17 Sep 2015 14:51:06 -0700 (PDT)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

>> My understanding is that the flow will be :
>>  sched_clock()
>>    rd->read_sched_clock() (cyc_to_ns() transformed for return)
>>      pxa_read_sched_clock()
>>        readl_relaxed(OSCR)
>> 
>> I didn't see any timings issue, as the flow looks equivalent to the readl(OSCR),
>> but I might have overlooked something.
>
> Of course it's different, because sched_clock() converts the value read
> from OSCR into nanoseconds, which is obviously different from using the
> OSCR register value directly.
>
> You're therefore feeding different values into this IRDA code.
Ah yes, I see it.
Which brings me to wonder which is the more correct :
 (a) replace to reproduce the same calculation
     Previously mtt was compared to a difference of 76ns steps (as 307ns / 4 =
     76ns):
     while ((sched_clock() - si->last_clk) * 76 < mtt)

 (b) change the calculation assuming mtt is in microseconds :
     while ((sched_clock() - si->last_clk) * 1000 < mtt)

I have no IRDA protocol knowledge so unless someone points me to the correct
calculation I'll try my luck with (b).

Cheers.

-- 
Robert
