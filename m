From: Sudeep Holla <sudeep.holla@arm.com>
Subject: Re: [PATCH 13/17] net: gianfar: remove misuse of IRQF_NO_SUSPEND flag
Date: Mon, 21 Sep 2015 17:38:48 +0100
Message-ID: <56003298.2010404@arm.com>
References: <1442850433-5903-1-git-send-email-sudeep.holla@arm.com>
 <1442850433-5903-14-git-send-email-sudeep.holla@arm.com>
 <BY2PR0301MB072700F43F00CFC273FED1B59C460@BY2PR0301MB0727.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sudeep Holla <sudeep.holla@arm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	"David S. Miller" <davem@davemloft.net>,
	Kevin Hao <haokexin@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Manoil Claudiu <claudiu.manoil@freescale.com>,
	"linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BY2PR0301MB072700F43F00CFC273FED1B59C460@BY2PR0301MB0727.namprd03.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 21/09/15 17:24, Manoil Claudiu wrote:
>> -----Original Message-----
>> From: Sudeep Holla [mailto:sudeep.holla@arm.com]
>> Sent: Monday, September 21, 2015 6:47 PM
>> To: linux-pm@vger.kernel.org; linux-kernel@vger.kernel.org
>> Cc: Sudeep Holla <sudeep.holla@arm.com>; Thomas Gleixner
>> <tglx@linutronix.de>; Rafael J. Wysocki <rjw@rjwysocki.net>; David S. Miller
>> <davem@davemloft.net>; Manoil Claudiu-B08782
>> <claudiu.manoil@freescale.com>; Kevin Hao <haokexin@gmail.com>;
>> netdev@vger.kernel.org
>> Subject: [PATCH 13/17] net: gianfar: remove misuse of IRQF_NO_SUSPEND
>> flag
>>
>> The device is set as wakeup capable using proper wakeup API but the
>> driver misuses IRQF_NO_SUSPEND to set the interrupt as wakeup source
>> which is incorrect.
>>
>> This patch removes the use of IRQF_NO_SUSPEND flags replacing it with
>> enable_irq_wake instead.
>>
>
> What would be the purpose of IRQF_NO_SUSPEND flag then?

If you look at the section "IRQF_NO_SUSPEND Flag" in
Documentation/power/suspend-and-interrupts.txt, it states it doesn't
guarantee that the interrupt will wake the system from a suspended state
-- for such cases it is necessary to use enable_irq_wake().

> The flag is a friendlier API compared to calling enable_irq_wake().

In what sense ?

> For older kernels, on PPC architectures, the flag did the job.

Agreed, it does the job even now, just that it's not designed for that.
One can change that anytime internally as the APIs for configuring
wakeups as in place now. I am just making use of right APIs.

> When did this change? Since when using IRQF_NO_SUSPEND is a "misuse"?
>

Sorry if the term "misuse" is not appropriate here, since the intention
of the flag usage doesn't meet the requirements, I mentioned it as misuse.

Regards,
Sudeep
