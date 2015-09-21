From: Thomas Gleixner <tglx@linutronix.de>
Subject: RE: [PATCH 13/17] net: gianfar: remove misuse of IRQF_NO_SUSPEND
 flag
Date: Mon, 21 Sep 2015 18:51:31 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1509211848510.5606@nanos>
References: <1442850433-5903-1-git-send-email-sudeep.holla@arm.com> <1442850433-5903-14-git-send-email-sudeep.holla@arm.com> <BY2PR0301MB072700F43F00CFC273FED1B59C460@BY2PR0301MB0727.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Sudeep Holla <sudeep.holla@arm.com>,
	"linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	"David S. Miller" <davem@davemloft.net>,
	Kevin Hao <haokexin@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Manoil Claudiu <claudiu.manoil@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BY2PR0301MB072700F43F00CFC273FED1B59C460@BY2PR0301MB0727.namprd03.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 21 Sep 2015, Manoil Claudiu wrote:
> >The device is set as wakeup capable using proper wakeup API but the
> >driver misuses IRQF_NO_SUSPEND to set the interrupt as wakeup source
> >which is incorrect.
> >
> >This patch removes the use of IRQF_NO_SUSPEND flags replacing it with
> >enable_irq_wake instead.
> >
> 
> What would be the purpose of IRQF_NO_SUSPEND flag then?  The flag is a
> friendlier API compared to calling enable_irq_wake().  For older kernels,

It's not an API, it's just a bandaid for lazy programmers.

> on PPC architectures, the flag did the job.  When did this change? Since
> when using IRQF_NO_SUSPEND is a "misuse"?

It always was. Simply because IRQF_NO_SUSPEND has absolutely nothing
to do with wakeup interrupt sources. It's a flag which excludes the
interrupt from the suspend mechanism, but it does not flag it a wakeup
source.

Thanks,

	tglx
