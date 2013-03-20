From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v3 1/1 net-next] NET: FEC: dynamtic check DMA desc buff
 type
Date: Wed, 20 Mar 2013 19:09:17 +0000
Message-ID: <1363806557.2677.19.camel@bwh-desktop.uk.solarflarecom.com>
References: <1357265063-30528-1-git-send-email-Frank.Li@freescale.com>
	 <20130320160418.GG20530@pengutronix.de>
	 <1363800515.2677.13.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Frank Li <Frank.Li@freescale.com>, <lznuaa@gmail.com>,
	<davem@davemloft.net>, <s.hauer@pengutronix.de>,
	<netdev@vger.kernel.org>, <shawn.guo@linaro.org>,
	<linux-arm-kernel@lists.infradead.org>, <kernel@pengutronix.de>
To: Uwe =?ISO-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:34181 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752466Ab3CTTJV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 15:09:21 -0400
In-Reply-To: <1363800515.2677.13.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-03-20 at 17:28 +0000, Ben Hutchings wrote:
> On Wed, 2013-03-20 at 17:04 +0100, Uwe Kleine-K=C3=B6nig wrote:
> > Hello,
> >=20
> > On Fri, Jan 04, 2013 at 10:04:23AM +0800, Frank Li wrote:
> > > MX6 and mx28 support enhanced DMA descriptor buff to support 1588
> > > ptp. But MX25, MX3x, MX5x can't support enhanced DMA descriptor b=
uff.
> > > Check fec type and choose correct DMA descriptor buff type.
> > >=20
> > > Remove static config CONFIG_FEC_PTP.
> > > ptp function will be auto detected.
> > Your patch (now as ff43da86c69d76a726ffe7d1666148960dc1d108 in v3.9=
-rc1)
> > breaks building with CONFIG_FEC=3Dm:
> >=20
> > 	ERROR: "fec_ptp_init" [drivers/net/ethernet/freescale/fec.ko] unde=
fined!
> > 	ERROR: "fec_ptp_ioctl" [drivers/net/ethernet/freescale/fec.ko] und=
efined!
> > 	ERROR: "fec_ptp_start_cyclecounter" [drivers/net/ethernet/freescal=
e/fec.ko] undefined!
> >=20
> > IMHO you should build fec.o and fec_ptp.o into the same module as t=
hey
> > cannot live without each other anyhow.
>=20
> They are in the same module.  So I don't see how that error is possib=
le.

Sorry, I misread the Makefile.  They are either both built as modules o=
r
both built-in, but they are separate modules.

Ben.

> > Having said I wonder if it would be worthwile to support FEC withou=
t
> > PTP_1588_CLOCK. For example make the above three functions static
> > inlines if CONFIG_PTP_1588_CLOCK=3Dn and drop the select on the lat=
ter.
>=20
> See previous discussions:
> <http://thread.gmane.org/gmane.linux.kernel/1363200/focus=3D1376659>,
> <http://thread.gmane.org/gmane.linux.network/247963>,
> <http://thread.gmane.org/gmane.linux.network/247823/focus=3D248173>
>=20
> Ben.
>=20

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
