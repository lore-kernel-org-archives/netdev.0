From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH v3 1/1 net-next] NET: FEC: dynamtic check DMA desc buff
 type
Date: Wed, 20 Mar 2013 17:04:18 +0100
Message-ID: <20130320160418.GG20530@pengutronix.de>
References: <1357265063-30528-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lznuaa@gmail.com, davem@davemloft.net, s.hauer@pengutronix.de,
	netdev@vger.kernel.org, shawn.guo@linaro.org,
	linux-arm-kernel@lists.infradead.org, kernel@pengutronix.de
To: Frank Li <Frank.Li@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:40585 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752379Ab3CTQE1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 12:04:27 -0400
Content-Disposition: inline
In-Reply-To: <1357265063-30528-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Fri, Jan 04, 2013 at 10:04:23AM +0800, Frank Li wrote:
> MX6 and mx28 support enhanced DMA descriptor buff to support 1588
> ptp. But MX25, MX3x, MX5x can't support enhanced DMA descriptor buff.
> Check fec type and choose correct DMA descriptor buff type.
>=20
> Remove static config CONFIG_FEC_PTP.
> ptp function will be auto detected.
Your patch (now as ff43da86c69d76a726ffe7d1666148960dc1d108 in v3.9-rc1=
)
breaks building with CONFIG_FEC=3Dm:

	ERROR: "fec_ptp_init" [drivers/net/ethernet/freescale/fec.ko] undefine=
d!
	ERROR: "fec_ptp_ioctl" [drivers/net/ethernet/freescale/fec.ko] undefin=
ed!
	ERROR: "fec_ptp_start_cyclecounter" [drivers/net/ethernet/freescale/fe=
c.ko] undefined!

IMHO you should build fec.o and fec_ptp.o into the same module as they
cannot live without each other anyhow.

Having said I wonder if it would be worthwile to support FEC without
PTP_1588_CLOCK. For example make the above three functions static
inlines if CONFIG_PTP_1588_CLOCK=3Dn and drop the select on the latter.

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
