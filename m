From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH v4 08/10] ARM: mxs: add ocotp read function
Date: Fri, 14 Jan 2011 21:16:56 +0800
Message-ID: <20110114131655.GB27583@freescale.com>
References: <1294297998-26930-1-git-send-email-shawn.guo@freescale.com>
	<1294297998-26930-9-git-send-email-shawn.guo@freescale.com>
	<20110113151939.GX24920@pengutronix.de>
	<20110114083320.GK26617@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: gerg@snapgear.com, B32542@freescale.com, netdev@vger.kernel.org,
	bryan.wu@canonical.com, jamie@shareable.org, baruch@tkos.co.il,
	w.sang@pengutronix.de, r64343@freescale.com, eric@eukrea.com,
	Uwe =?iso-8859-1?Q?Kleine-K=F6nig?= <u.kleine-koenig@pengutronix.de>,
	jamie@jamieiles.com, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org, lw@karo-electronics.de
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <20110114083320.GK26617@pengutronix.de>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 14, 2011 at 09:33:20AM +0100, Sascha Hauer wrote:
> On Thu, Jan 13, 2011 at 04:19:39PM +0100, Uwe Kleine-K=F6nig wrote:
> > On Thu, Jan 06, 2011 at 03:13:16PM +0800, Shawn Guo wrote:
> > > Signed-off-by: Shawn Guo <shawn.guo@freescale.com>
> > > ---
> > > Changes for v4:
> > >  - Call cpu_relax() during polling
> > > =

> > > Changes for v2:
> > >  - Add mutex locking for mxs_read_ocotp()
> > >  - Use type size_t for count and i
> > >  - Add comment for clk_enable/disable skipping
> > >  - Add ERROR bit clearing and polling step
> > > =

> > >  arch/arm/mach-mxs/Makefile              |    2 +-
> > >  arch/arm/mach-mxs/include/mach/common.h |    1 +
> > >  arch/arm/mach-mxs/ocotp.c               |   79 +++++++++++++++++++++=
++++++++++
> > >  3 files changed, 81 insertions(+), 1 deletions(-)
> > >  create mode 100644 arch/arm/mach-mxs/ocotp.c
> > > =

> > > diff --git a/arch/arm/mach-mxs/Makefile b/arch/arm/mach-mxs/Makefile
> > > index 39d3f9c..f23ebbd 100644
> > > --- a/arch/arm/mach-mxs/Makefile
> > > +++ b/arch/arm/mach-mxs/Makefile
> > > @@ -1,5 +1,5 @@
> > >  # Common support
> > > -obj-y :=3D clock.o devices.o gpio.o icoll.o iomux.o system.o timer.o
> > > +obj-y :=3D clock.o devices.o gpio.o icoll.o iomux.o ocotp.o system.o=
 timer.o
> > is it worth to make ocotp optional?  (and let evk select
> > CONFIG_MXS_OCOTP)
> =

> I think not.
> =

I thought it depends on how we think about it.  If we think that
ocotp is a block of soc and should be on every system based on
the soc, we should build it unconditional.  However, if we think
ocotp is a function that could either be used on a machine or not,
it should be built conditional, so that the machine does not use
ocotp function could save the ocotp build and the memory of
u32 ocotp_words[0x20].

-- =

Regards,
Shawn
