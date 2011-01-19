From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH v4 08/10] ARM: mxs: add ocotp read function
Date: Wed, 19 Jan 2011 18:48:24 +0800
Message-ID: <20110119104823.GD2833@S2101-09.ap.freescale.net>
References: <1294297998-26930-1-git-send-email-shawn.guo@freescale.com>
 <1294297998-26930-9-git-send-email-shawn.guo@freescale.com>
 <20110113151939.GX24920@pengutronix.de>
 <20110114083320.GK26617@pengutronix.de>
 <20110114131655.GB27583@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <gerg@snapgear.com>, <B32542@freescale.com>,
	<netdev@vger.kernel.org>, <bryan.wu@canonical.com>,
	<jamie@shareable.org>, <baruch@tkos.co.il>,
	<w.sang@pengutronix.de>, <r64343@freescale.com>, <eric@eukrea.com>,
	Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>, <jamie@jamieiles.com>,
	<davem@davemloft.net>, <linux-arm-kernel@lists.infradead.org>,
	<lw@karo-electronics.de>
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe001.messaging.microsoft.com ([65.55.88.11]:13938 "EHLO
	TX2EHSOBE002.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751446Ab1ASCs1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 21:48:27 -0500
Received: from mail171-tx2 (localhost.localdomain [127.0.0.1])	by
 mail171-tx2-R.bigfish.com (Postfix) with ESMTP id 5245F1A58355	for
 <netdev@vger.kernel.org>; Wed, 19 Jan 2011 02:48:25 +0000 (UTC)
Received: from TX2EHSMHS020.bigfish.com (unknown [10.9.14.248])	by
 mail171-tx2.bigfish.com (Postfix) with ESMTP id 94D8CEA004F	for
 <netdev@vger.kernel.org>; Wed, 19 Jan 2011 02:48:24 +0000 (UTC)
Received: from az33smr02.freescale.net (az33smr02.freescale.net
 [10.64.34.200])	by de01egw02.freescale.net (8.14.3/8.14.3) with ESMTP id
 p0J2mKpP025752	for <netdev@vger.kernel.org>; Tue, 18 Jan 2011 19:48:21 -0700
 (MST)
Received: from S2101-09.ap.freescale.net (S2101-09.ap.freescale.net
 [10.192.242.113])	by az33smr02.freescale.net (8.13.1/8.13.0) with ESMTP id
 p0J2mJaj004804	for <netdev@vger.kernel.org>; Tue, 18 Jan 2011 20:48:20 -0600
 (CST)
Content-Disposition: inline
In-Reply-To: <20110114131655.GB27583@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sascha,

On Fri, Jan 14, 2011 at 09:16:56PM +0800, Shawn Guo wrote:
> On Fri, Jan 14, 2011 at 09:33:20AM +0100, Sascha Hauer wrote:
> > On Thu, Jan 13, 2011 at 04:19:39PM +0100, Uwe Kleine-K=F6nig wrote:
> > > On Thu, Jan 06, 2011 at 03:13:16PM +0800, Shawn Guo wrote:
> > > > Signed-off-by: Shawn Guo <shawn.guo@freescale.com>
> > > > ---
> > > > Changes for v4:
> > > >  - Call cpu_relax() during polling
> > > >=20
> > > > Changes for v2:
> > > >  - Add mutex locking for mxs_read_ocotp()
> > > >  - Use type size_t for count and i
> > > >  - Add comment for clk_enable/disable skipping
> > > >  - Add ERROR bit clearing and polling step
> > > >=20
> > > >  arch/arm/mach-mxs/Makefile              |    2 +-
> > > >  arch/arm/mach-mxs/include/mach/common.h |    1 +
> > > >  arch/arm/mach-mxs/ocotp.c               |   79 +++++++++++++++=
++++++++++++++++
> > > >  3 files changed, 81 insertions(+), 1 deletions(-)
> > > >  create mode 100644 arch/arm/mach-mxs/ocotp.c
> > > >=20
> > > > diff --git a/arch/arm/mach-mxs/Makefile b/arch/arm/mach-mxs/Mak=
efile
> > > > index 39d3f9c..f23ebbd 100644
> > > > --- a/arch/arm/mach-mxs/Makefile
> > > > +++ b/arch/arm/mach-mxs/Makefile
> > > > @@ -1,5 +1,5 @@
> > > >  # Common support
> > > > -obj-y :=3D clock.o devices.o gpio.o icoll.o iomux.o system.o t=
imer.o
> > > > +obj-y :=3D clock.o devices.o gpio.o icoll.o iomux.o ocotp.o sy=
stem.o timer.o
> > > is it worth to make ocotp optional?  (and let evk select
> > > CONFIG_MXS_OCOTP)
> >=20
> > I think not.
> >=20
> I thought it depends on how we think about it.  If we think that
> ocotp is a block of soc and should be on every system based on
> the soc, we should build it unconditional.  However, if we think
> ocotp is a function that could either be used on a machine or not,
> it should be built conditional, so that the machine does not use
> ocotp function could save the ocotp build and the memory of
> u32 ocotp_words[0x20].
>=20
You've not merged patch #8, #9, #10, so you still think
CONFIG_MXS_OCOTP should not be added?

--=20
Regards,
Shawn

