From: Sudeep Holla <sudeep.holla@arm.com>
Subject: Re: [PATCH 13/17] net: gianfar: remove misuse of IRQF_NO_SUSPEND flag
Date: Tue, 22 Sep 2015 16:09:48 +0100
Message-ID: <56016F3C.2070704@arm.com>
References: <1442850433-5903-1-git-send-email-sudeep.holla@arm.com>
 <1442850433-5903-14-git-send-email-sudeep.holla@arm.com>
 <BY2PR0301MB072700F43F00CFC273FED1B59C460@BY2PR0301MB0727.namprd03.prod.outlook.com>
 <alpine.DEB.2.11.1509211848510.5606@nanos>
 <BY2PR0301MB072767325C2CBDB3D5CA8E1A9C450@BY2PR0301MB0727.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sudeep Holla <sudeep.holla@arm.com>,
	"linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	"David S. Miller" <davem@davemloft.net>,
	Kevin Hao <haokexin@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Manoil Claudiu <claudiu.manoil@freescale.com>,
	Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BY2PR0301MB072767325C2CBDB3D5CA8E1A9C450@BY2PR0301MB0727.namprd03.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 22/09/15 15:04, Manoil Claudiu wrote:
>> -----Original Message-----
>> From: Thomas Gleixner [mailto:tglx@linutronix.de]

[...]

>>> on PPC architectures, the flag did the job.  When did this change? Since
>>> when using IRQF_NO_SUSPEND is a "misuse"?
>>
>> It always was. Simply because IRQF_NO_SUSPEND has absolutely nothing
>> to do with wakeup interrupt sources. It's a flag which excludes the
>> interrupt from the suspend mechanism, but it does not flag it a wakeup
>> source.
>>
>
> I'm seeing also a "powerpc: mpic" patch in the series, unfortunately I can't

Yes I think that was a redundant code, so I removed it. IIRC it was
setting IRQF_NO_SUSPEND in irq_set_wake callback which again is incorrect.

> afford to test it right now. However I ran a quick test with this gianfar patch
> in isolation on a powerpc system, and seen some difference in the behavior
> (with and w/o the patch).  In both cases the system wakes up from standby
> by magic packet.  However, without the IRQF_NO_SUSPEND flag 2 wake-up
> interrupts are reported in /proc/interrupts for one magic packet; with the

OK that's interesting, will have check if I have similar behavior on my
setup too.

> flag on there's just 1 interrupt.  Maybe this is not relevant, maybe the
> "powerpc: mpic" patch from this series changes this behavior.

Hmm not sure, but better to test it together if possible. If required we
can reorder for bisect-ability reasons.

> But if this is the API, what can I say? We'll see in time.  Btw, enable_irq_wake()
> returns an error code, normally it should be handled by printing a warning
> message at least, right?  But since most drivers don't handle that, I'm assuming
> it should be left unhandled to avoid overcomplicating things.

Yes I left it so that I can add if the maintainer insist and not churn
too much code adding warning.

> FWIW
> Acked-by: Claudiu Manoil <claudiu.manoil@freescale.com>
>

Thanks.

Regards,
Sudeep
