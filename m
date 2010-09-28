From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v6 0/8] ptp: IEEE 1588 hardware clock support
Date: Tue, 28 Sep 2010 08:47:10 +0200
Message-ID: <20100928064710.GB7224@riccoc20.at.omicron.at>
References: <cover.1285261533.git.richard.cochran@omicron.at>
 <20100923213654.0c64b047@lxorguk.ukuu.org.uk>
 <20100924131407.GA3113@riccoc20.at.omicron.at>
 <20100924150246.0e6064b6@lxorguk.ukuu.org.uk>
 <alpine.DEB.2.00.1009271054320.9258@router.home>
 <20100927180558.52817d5f@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org, linux-api@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	David Miller <davem@davemloft.net>,
	John Stultz <johnstul@us.ibm.com>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Peter Zijlstra <peterz@infradead.org>,
	Rodolfo Giometti <giometti@linux.it>,
	Thomas Gleixner <tglx@linutronix.de>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100927180558.52817d5f@lxorguk.ukuu.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 27, 2010 at 06:05:58PM +0100, Alan Cox wrote:
> On Mon, 27 Sep 2010 10:56:09 -0500 (CDT)
> Christoph Lameter <cl@linux.com> wrote:
> 
> > 
> > On Fri, 24 Sep 2010, Alan Cox wrote:
> > 
> > > Whether you add new syscalls or do the fd passing using flags and hide
> > > the ugly bits in glibc is another question.
> > 
> > Use device specific ioctls instead of syscalls?
> 
> Some of the ioctls are probably not device specific, the job of the OS in
> part is to present a unified interface. We already have a mess of HPET
> and RTC driver ioctls.

Yes, and the whole point of introducing a PTP hardare clock API was to
avoid each new clock driver introducing yet another ioctl interface.

I had proposed a standard ioctl interface for PTP hardware clocks, but
that interface was rightly criticized for duplicating the posix clock
API. It does not make sense to have multiple interfaces with the exact
same functionality.

It is impossible to support every last feature of every possible
hardware clock with a generic interface, so there will always need to
be special ioctls for such features.

However, some clock functions *are* completely generic and apply to
every clock:

- set time
- get time
- adjust the frequency by N ppb
- shift the time by a given offset

The first two are provided by the posix clock interface, the third by
the NTP adjtimex call, which also can support (by a single mode
extension) the last item.

Richard
