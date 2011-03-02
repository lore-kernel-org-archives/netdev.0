From: Peppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH (sh-2.6) 1/4] clksource: Generic timer infrastructure
Date: Wed, 2 Mar 2011 18:35:19 +0100
Message-ID: <4D6E7FD7.1060408@st.com>
References: <1298369864-24429-1-git-send-email-peppe.cavallaro@st.com>
 <1298369864-24429-2-git-send-email-peppe.cavallaro@st.com>
 <201102241820.55873.arnd@arndb.de> <4D6D0EA3.9000504@st.com>
 <alpine.LFD.2.00.1103011630080.2701@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Stuart MENEFY <stuart.menefy@st.com>,
	Arnd Bergmann <arnd@arndb.de>,
	"linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	John Stultz <johnstul@us.ibm.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux@arm.linux.org.uk" <linux@arm.linux.org.uk>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1103011630080.2701@localhost6.localdomain6>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello and many thanks to All for your feedback.

On 3/1/2011 5:48 PM, Thomas Gleixner wrote:
>
> On Tue, 1 Mar 2011, Stuart Menefy wrote:
> > On 24/02/11 17:20, Arnd Bergmann wrote:
> > > On Tuesday 22 February 2011, Peppe CAVALLARO wrote:
> > >> From: Stuart Menefy <stuart.menefy@st.com>
> > >>
> > >> Many devices targeted at the embedded market provide a number of
> > >> generic timers which are capable of generating interrupts at a
> > >> requested rate. These can then be used in the implementation of
> drivers
> > >> for other peripherals which require a timer interrupt, without having
> > >> to provide an additional timer as part of that peripheral.
>
> Why can't you just use an hrtimer and be done with it? Just because
> there is some extra hardware in the chip?
>
> > If anything this duplicates clockevents. The main reason for not using
> > clockevents was that nobody else does! Currently clockevents are
> > used strictly for time keeping within the kernel, and most architectures
> > only register those which are intended to be used for this purpose.
> > We felt a bit nervous about adding code to register all the device's
> timers
> > as clockevents, and having the network device driver pick up one of
> those
> > for its own use.
>
> We had this discussion before and there was never an real outcome as
> it turned out that hrtimers provide enough abstraction for this kind
> of problems.
>
> > True. The intent was that this would be a third interface onto timer
> > hardware, alongside clocksources and clockevents.
> >
> > > I don't know if this could also be merged with the clocksource
> infrastructure,
> > > but your code currently doesn't do that.
> >
> > It would probably be clockevent rather than clocksource, but it
> could be if
> > people felt that was a better way to go.
>
> If we get some reasonable explanation why an extra timer interrupt is
> solving a specific problem better than hrtimers we can do that, but
> that needs more thought than picking the first available clockevent
> from a list. If we come to the conclusion, that we want/need this kind
> of functionality then I really prefer not to create yet another piece
> of infrastructure which deals with timer devices.
>

The initial/main usage of this code was to provide
an interrupt timer to handle the rx/tx processes in
the stmmac Ethernet d.d.

Some Ethernet devices have embedded timer
used for mitigating the number of their DMA interrupts.
So, to be frankly, my first idea was to use an
extra HW (SH4 TMU channel 2), unused on our platforms,
because our MAC hadn't something like that.

I'm not sure if other Ethernet drivers use hrtimer for
handling the whole rx/tx processes (on CC the net-2.6 ML:
please correct me if I'm wrong) and if this could have
impact on the performances or reliability of the network
activity (pkt loss%).

At any rate, I am happy to use the stmmac as experimental
driver to do this kind tests.
Indeed, in the past, on old Kernel (IIRC 2.6.23), I tried to use
the kernel timers but I removed the code from it because
I had noticed packets loss and a strange phenomenon with cyclesoak
(that showed broken sysload % during the heavy network activities).

Let me know how to proceed:

1) experiment with stmmac and hrtimer for handling rx/tx?
2) rework the patches for the Generic Timer Infra?

Best Regards,
Peppe

> Thanks,
>
>         tglx
>
