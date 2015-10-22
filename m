From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 1/2] can: xilinx: use readl/writel instead of ioread/iowrite
Date: Thu, 22 Oct 2015 11:02:38 +0200
Message-ID: <3847286.pUBWjpC1TL@wuerfel>
References: <1445489163-11045-1-git-send-email-appanad@xilinx.com> <4061693.oBld7AKBIp@wuerfel> <C246CAC1457055469EF09E3A7AC4E11A4A4F2CDB@XAP-PVEXMBX01.xlnx.xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Appana Durga Kedareswara Rao <appana.durga.rao@xilinx.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	Michal Simek <michals@xilinx.com>,
	Soren Brinkmann <sorenb@xilinx.com>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	"mkl@pengutronix.de" <mkl@pengutronix.de>,
	"wg@grandegger.com" <wg@grandegger.com>
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <C246CAC1457055469EF09E3A7AC4E11A4A4F2CDB@XAP-PVEXMBX01.xlnx.xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 22 October 2015 08:34:53 Appana Durga Kedareswara Rao wrote:
> > On Thursday 22 October 2015 10:16:02 Kedareswara rao Appana wrote:
> > > The driver only supports memory-mapped I/O [by ioremap()], so
> > > readl/writel is actually the right thing to do, IMO.
> > > During the validation of this driver or IP on ARM 64-bit processor
> > > while sending lot of packets observed that the tx packet drop with
> > > iowrite Putting the barriers for each tx fifo register write fixes
> > > this issue Instead of barriers using writel also fixed this issue.
> > >
> > > Signed-off-by: Kedareswara rao Appana <appanad@xilinx.com>
> > 
> > The two should really do the same thing: iowrite32() is just a static inline calling
> > writel() on both ARM32 and ARM64. On which kernel version did you observe the
> > difference? It's possible that an older version used CONFIG_GENERIC_IOMAP,
> > which made this slightly more expensive.
> 
> I observed this issue with the 4.0.0 kernel version

Is it possible that you have nonstandard patches on your kernel? If so, can
you send a diff against the mainline version?

I don't see CONFIG_GENERIC_IOMAP in 4.0.0, and writel() definitely has the
necessary barriers on arm64, the same way that iowrite() does.

> > If there are barriers that you want to get rid of for performance reasons, you
> > should use writel_relaxed(), but be careful to synchronize them correctly with
> > regard to DMA. It should be fine in this driver, as it does not perform any DMA,
> > but be aware that there is no big-endian version of
> > writel_relaxed() at the moment.
> 
> There is no DMA in CAN for this IP.

Ok, good.

	Arnd
