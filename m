From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH V14 3/4] ptp: Added a clock driver for the IXP46x.
Date: Mon, 18 Apr 2011 10:21:01 +0200
Message-ID: <201104181021.01279.arnd@arndb.de>
References: <cover.1303107532.git.richard.cochran@omicron.at>
	<201104180856.04186.arnd@arndb.de>
	<20110418080606.GA3809@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Gleixner <tglx@linutronix.de>, Rodolfo Giometti <giometti@linux.it>,
	Peter Zijlstra <peterz@infradead.org>, linux-api@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org, linux-kernel@vger.kernel.org,
	Russell King <linux@arm.linux.org.uk>, Paul Mackerras <paulus@samba.org>,
	John Stultz <john.stultz@linaro.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>, netdev@vger.kernel.org,
	Mike Frysinger <vapier@gentoo.org>,
	Christoph Lameter <cl@linux.com>, linuxppc-dev@lists.ozlabs.org,
	David Miller <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org,
	Krzysztof Halasa <khc@pm.waw.pl>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <20110418080606.GA3809@riccoc20.at.omicron.at>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

On Monday 18 April 2011, Richard Cochran wrote:
> On Mon, Apr 18, 2011 at 08:56:03AM +0200, Arnd Bergmann wrote:
> > On Monday 18 April 2011, Richard Cochran wrote:
> > > +
> > > +       lo = __raw_readl(&regs->channel[ch].src_uuid_lo);
> > > +       hi = __raw_readl(&regs->channel[ch].src_uuid_hi);
> > > +
> > 
> > I guess you should use readl(), not __raw_readl() here. The __raw_* functions
> > are not meant for device drivers.
> 
> Krzysztof had a different opinion about this.
> 
>     https://lkml.org/lkml/2011/1/8/67
> 
> Anyway, it is his driver, and I just followed what he does elsewhere
> in the driver. It make sense to me to keep the driver consistent.
> Maybe we should make the change throughout?

It would certainly be useful to fix it up. I now realized that this driver
supports both big-endian and little-endian configurations, so just using
readl() is certainly broken.
There should probably be an ixp specific version of the safe I/O accessors
to deal with it on all on-chip peripherals in a safe way.

	Arnd
