From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [RESEND PATCH -net] cpsw/netcp: cpts depends on posix_timers
Date: Mon, 13 Mar 2017 16:41:39 -0400 (EDT)
Message-ID: <alpine.LFD.2.20.1703131629570.14436@knanqh.ubzr>
References: <20170313165849.1378558-1-arnd@arndb.de> <alpine.LFD.2.20.1703131608100.14436@knanqh.ubzr> <CAK8P3a125rioB5Cnoa7nR9Dz_pU5=x7=06_DvXEE-dTpOBiitQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>, stable@vger.kernel.org,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        John Stultz <john.stultz@linaro.org>,
        Networking <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <CAK8P3a125rioB5Cnoa7nR9Dz_pU5=x7=06_DvXEE-dTpOBiitQ@mail.gmail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 13 Mar 2017, Arnd Bergmann wrote:

> On Mon, Mar 13, 2017 at 9:09 PM, Nicolas Pitre <nicolas.pitre@linaro.org> wrote:
> > On Mon, 13 Mar 2017, Arnd Bergmann wrote:
> >
> >> With posix timers having become optional, we get a build error with
> >> the cpts time sync option of the CPSW driver:
> >>
> >> drivers/net/ethernet/ti/cpts.c: In function 'cpts_find_ts':
> >> drivers/net/ethernet/ti/cpts.c:291:23: error: implicit declaration of function 'ptp_classify_raw';did you mean 'ptp_classifier_init'? [-Werror=implicit-function-declaration]
> >>
> >> It really makes no sense to build this driver if we can't use PTP,
> >> so it's better to go back to 'select PTP_1588_CLOCK' but instead
> >> add a dependency on POSIX_TIMERS. Adding 'depends on PTP_1588_CLOCK'
> >> might also work, but has the risk of circular dependencies when
> >> mixed with other drivers using 'imply'.
> >
> > Could you elaborate on that risk please?
> 
> I have seen many circular dependencies in the past that tend to be of type
> 
> config FOO
>      depends on A
>      select B
> 
> config BAR
>      select A
>      depends on B

This is really a problem?  I mean in this example there is nothing that 
prevents A or B to be enabled independently.  Of course if you had:

config A
	depends on B

config B
	depends on A

then the circular dependency is obvious.

> The best way to avoid this problem is to only ever use either 'select' or
> 'depends on' for any given dependency, but not both. In this case, almost
> all references to PTP_1588_CLOCK use 'select' or 'implies', so I don't
> want to introduce any more 'depends on'.

I can't find any "select PTP_1588_CLOCK" in the tree.

The "imply" keyword in itself doesn't create nor inforce any 
dependencies -- that's why it was created in the first place.

So unless I'm mistaken I don't see any problem using "depends on 
PTP_1588_CLOCK" here.


Nicolas
