From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v6 0/8] ptp: IEEE 1588 hardware clock support
Date: Thu, 23 Sep 2010 13:36:41 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1009231327000.2962@router.home>
References: <cover.1285261533.git.richard.cochran@omicron.at> <alpine.DEB.2.00.1009231238170.2962@router.home> <AANLkTim0JqVTyvrvjLRp1Cg423MdrwmyZG2uN6uSyeLb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Richard Cochran <richardcochran@gmail.com>,
	linux-kernel@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	linux-api@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	David Miller <davem@davemloft.net>,
	John Stultz <johnstul@us.ibm.com>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Peter Zijlstra <peterz@infradead.org>,
	Rodolfo Giometti <giometti@linux.it>,
	Thomas Gleixner <tglx@linutronix.de>
To: Jacob Keller <jacob.keller@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTim0JqVTyvrvjLRp1Cg423MdrwmyZG2uN6uSyeLb@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 23 Sep 2010, Jacob Keller wrote:

> > There is a reason for not being able to shift posix clocks: The system has
> > one time base. The various clocks are contributing to maintaining that
> > sytem wide time.
> >
> > Adjusting clocks is absolutely essential for proper functioning of the PTP
> protocol. The slave obtains and calculates the offset from master and uses
> that in order to adjust the clock properly, The problem is that the
> timestamps are done via the hardware. We need a method to expose that
> hardware so that the ptp software can properly adjust those clocks.

There is no way to use that clock directly to avoid all the user space
tuning etc? There are already tuning mechanisms in the kernel that do this
with system time based on periodic clocks. If you calculate the
nanoseconds since the epoch then you should be able to use that to tune
system time.

> > I do not understand why you want to maintain different clocks running at
> > different speeds. Certainly interesting for some uses I guess that I
> > do not have the energy to imagine right now. But can we get the PTP killer
> > feature of synchronized accurate system time first?
> >
>
> The problem is maintaining a hardware clock at the correct speed/frequency
> and time. The timestamping is done via hardware, and that hardware clock
> needs to be accurate. We need to be able to modify that clock. Yes, having
> the system time be the same value would be nice, but the problem comes
> because we don't want to jump through hoops to keep that hardware clock
> accurate to the ptp protocol running on the network.

Then allow system time == hardware clock?

> All of the necessary features for microsecond or better accuracy are done
> via the hardware. You can get accuracy to within <10 mircoseconds while only
> sending sync packets and such once per second. The reason is because the
> hardware timestamps are very accurate. But if we can't properly adjust the
> clocks time and frequency, we cannot maintain the accuracy of the
> timestamps.

You can already adjust the system time with the existing APIs. Tuning
hardware clocks is currently done using device specific controls. But I
would think that you do not need to expose this to user space if you can
do it all in kernel.
