From: Li Yang <leoli@freescale.com>
Subject: Re: [PATCH 13/17] net: gianfar: remove misuse of IRQF_NO_SUSPEND flag
Date: Wed, 23 Sep 2015 16:20:16 -0500
Message-ID: <CADRPPNS_8PBHmm7jpindmg9pA5yEerM96JdpBtBz5BqOBFdUkw@mail.gmail.com>
References: <1442850433-5903-1-git-send-email-sudeep.holla@arm.com>
	<1442850433-5903-14-git-send-email-sudeep.holla@arm.com>
	<BY2PR0301MB072700F43F00CFC273FED1B59C460@BY2PR0301MB0727.namprd03.prod.outlook.com>
	<alpine.DEB.2.11.1509211848510.5606@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Manoil Claudiu <claudiu.manoil@freescale.com>,
	Sudeep Holla <sudeep.holla@arm.com>,
	"linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	"David S. Miller" <davem@davemloft.net>,
	Kevin Hao <haokexin@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.11.1509211848510.5606@nanos>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 21, 2015 at 11:51 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
> On Mon, 21 Sep 2015, Manoil Claudiu wrote:
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
> It's not an API, it's just a bandaid for lazy programmers.
>
>> on PPC architectures, the flag did the job.  When did this change? Since
>> when using IRQF_NO_SUSPEND is a "misuse"?
>
> It always was. Simply because IRQF_NO_SUSPEND has absolutely nothing
> to do with wakeup interrupt sources. It's a flag which excludes the
> interrupt from the suspend mechanism, but it does not flag it a wakeup
> source.

It was not very clear on the intended use of IRQF_NO_SUSPEND at the
beginning as it was not documented anywhere.  It's good that we have
the Documentation/power/suspend-and-interrupts.txt to clarify that
now.

Regards,
Leo
