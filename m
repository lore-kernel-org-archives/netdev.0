From: Manoil Claudiu <claudiu.manoil@freescale.com>
Subject: RE: [PATCH 13/17] net: gianfar: remove misuse of IRQF_NO_SUSPEND flag
Date: Tue, 22 Sep 2015 14:04:53 +0000
Message-ID: <BY2PR0301MB072767325C2CBDB3D5CA8E1A9C450@BY2PR0301MB0727.namprd03.prod.outlook.com>
References: <1442850433-5903-1-git-send-email-sudeep.holla@arm.com>
 <1442850433-5903-14-git-send-email-sudeep.holla@arm.com>
 <BY2PR0301MB072700F43F00CFC273FED1B59C460@BY2PR0301MB0727.namprd03.prod.outlook.com>
 <alpine.DEB.2.11.1509211848510.5606@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Sudeep Holla <sudeep.holla@arm.com>,
	"linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	"David S. Miller" <davem@davemloft.net>,
	Kevin Hao <haokexin@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.11.1509211848510.5606@nanos>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>-----Original Message-----
>From: Thomas Gleixner [mailto:tglx@linutronix.de]
>Sent: Monday, September 21, 2015 7:52 PM
>To: Manoil Claudiu-B08782 <claudiu.manoil@freescale.com>
>Cc: Sudeep Holla <sudeep.holla@arm.com>; linux-pm@vger.kernel.org; linux-
>kernel@vger.kernel.org; Rafael J. Wysocki <rjw@rjwysocki.net>; David S.
>Miller <davem@davemloft.net>; Kevin Hao <haokexin@gmail.com>;
>netdev@vger.kernel.org
>Subject: RE: [PATCH 13/17] net: gianfar: remove misuse of
>IRQF_NO_SUSPEND flag
>
>On Mon, 21 Sep 2015, Manoil Claudiu wrote:
>> >The device is set as wakeup capable using proper wakeup API but the
>> >driver misuses IRQF_NO_SUSPEND to set the interrupt as wakeup source
>> >which is incorrect.
>> >
>> >This patch removes the use of IRQF_NO_SUSPEND flags replacing it with
>> >enable_irq_wake instead.
>> >
>>
>> What would be the purpose of IRQF_NO_SUSPEND flag then?  The flag is a
>> friendlier API compared to calling enable_irq_wake().  For older kernels,
>
>It's not an API, it's just a bandaid for lazy programmers.
>
>> on PPC architectures, the flag did the job.  When did this change? Since
>> when using IRQF_NO_SUSPEND is a "misuse"?
>
>It always was. Simply because IRQF_NO_SUSPEND has absolutely nothing
>to do with wakeup interrupt sources. It's a flag which excludes the
>interrupt from the suspend mechanism, but it does not flag it a wakeup
>source.
>

I'm seeing also a "powerpc: mpic" patch in the series, unfortunately I can't
afford to test it right now. However I ran a quick test with this gianfar patch
in isolation on a powerpc system, and seen some difference in the behavior
(with and w/o the patch).  In both cases the system wakes up from standby
by magic packet.  However, without the IRQF_NO_SUSPEND flag 2 wake-up
interrupts are reported in /proc/interrupts for one magic packet; with the
flag on there's just 1 interrupt.  Maybe this is not relevant, maybe the
"powerpc: mpic" patch from this series changes this behavior.
But if this is the API, what can I say? We'll see in time.  Btw, enable_irq_wake()
returns an error code, normally it should be handled by printing a warning
message at least, right?  But since most drivers don't handle that, I'm assuming
it should be left unhandled to avoid overcomplicating things.
FWIW
Acked-by: Claudiu Manoil <claudiu.manoil@freescale.com>
