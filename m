From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH (sh-2.6) 1/4] clksource: Generic timer infrastructure
Date: Tue, 1 Mar 2011 17:48:33 +0100 (CET)
Message-ID: <alpine.LFD.2.00.1103011630080.2701@localhost6.localdomain6>
References: <1298369864-24429-1-git-send-email-peppe.cavallaro@st.com> <1298369864-24429-2-git-send-email-peppe.cavallaro@st.com> <201102241820.55873.arnd@arndb.de> <4D6D0EA3.9000504@st.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Arnd Bergmann <arnd@arndb.de>,
	Peppe CAVALLARO <peppe.cavallaro@st.com>,
	"linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	John Stultz <johnstul@us.ibm.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Stuart Menefy <stuart.menefy@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D6D0EA3.9000504@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 1 Mar 2011, Stuart Menefy wrote:
> On 24/02/11 17:20, Arnd Bergmann wrote:
> > On Tuesday 22 February 2011, Peppe CAVALLARO wrote:
> >> From: Stuart Menefy <stuart.menefy@st.com>
> >>
> >> Many devices targeted at the embedded market provide a number of
> >> generic timers which are capable of generating interrupts at a
> >> requested rate. These can then be used in the implementation of drivers
> >> for other peripherals which require a timer interrupt, without having
> >> to provide an additional timer as part of that peripheral.

Why can't you just use an hrtimer and be done with it? Just because
there is some extra hardware in the chip?

> If anything this duplicates clockevents. The main reason for not using
> clockevents was that nobody else does! Currently clockevents are
> used strictly for time keeping within the kernel, and most architectures
> only register those which are intended to be used for this purpose.
> We felt a bit nervous about adding code to register all the device's timers
> as clockevents, and having the network device driver pick up one of those
> for its own use.

We had this discussion before and there was never an real outcome as
it turned out that hrtimers provide enough abstraction for this kind
of problems.
 
> True. The intent was that this would be a third interface onto timer
> hardware, alongside clocksources and clockevents.
> 
> > I don't know if this could also be merged with the clocksource infrastructure,
> > but your code currently doesn't do that.
> 
> It would probably be clockevent rather than clocksource, but it could be if
> people felt that was a better way to go.

If we get some reasonable explanation why an extra timer interrupt is
solving a specific problem better than hrtimers we can do that, but
that needs more thought than picking the first available clockevent
from a list. If we come to the conclusion, that we want/need this kind
of functionality then I really prefer not to create yet another piece
of infrastructure which deals with timer devices.

Thanks,

	tglx
