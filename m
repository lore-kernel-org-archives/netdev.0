From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 1/2] can: xilinx: use readl/writel instead of ioread/iowrite
Date: Mon, 26 Oct 2015 02:25:30 +0100
Message-ID: <201510260225.30934.arnd@arndb.de>
References: <1445489163-11045-1-git-send-email-appanad@xilinx.com> <8460953.p47oezaZnR@wuerfel> <562D3C4C.60306@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org,
	Kedareswara rao Appana <appana.durga.rao@xilinx.com>,
	anirudh@xilinx.com, wg@grandegger.com, michal.simek@xilinx.com,
	soren.brinkmann@xilinx.com, appanad@xilinx.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-can@vger.kernel.org
To: "Marc Kleine-Budde" <mkl@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <562D3C4C.60306@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 25 October 2015, Marc Kleine-Budde wrote:
> On 10/22/2015 10:58 AM, Arnd Bergmann wrote:
> >>> The two should really do the same thing: iowrite32() is just a static inline
> >>> calling writel() on both ARM32 and ARM64. On which kernel version did you
> >>> observe the difference? It's possible that an older version used
> >>> CONFIG_GENERIC_IOMAP, which made this slightly more expensive.
> >>>
> >>> If there are barriers that you want to get rid of for performance reasons,
> >>> you should use writel_relaxed(), but be careful to synchronize them correctly
> >>> with regard to DMA. It should be fine in this driver, as it does not
> >>> perform any DMA, but be aware that there is no big-endian version of
> >>> writel_relaxed() at the moment.
> >>
> >> We don't have DMA in CAN drivers, but usually a certain write triggers
> >> sending. Do we need a barrier before triggering the sending?
> > 
> > No, the relaxed writes are not well-defined across architectures. On
> > ARM, the CPU guarantees that stores to an MMIO area are still in order
> > with respect to one another, the barrier is only needed for actual DMA,
> > so you are fine. I would expect the same to be true everywhere,
> > otherwise a lot of other drivers would be broken too.
> 
> And the relaxed functions seem not to be available on all archs. This
> driver should work on microblaze. Are __raw_writeX(), __raw_readX() an
> alternative here?

__raw_writeX() and __raw_readX()  are not safe to use in drivers in general.

readl_relaxed() should work on all architectures nowadays, and I've checked
that it does on microblaze.

	Arnd
