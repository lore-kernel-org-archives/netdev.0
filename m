From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next V2 13/16] net: fec: print more debug info in
 fec_timeout
Date: Fri, 04 Mar 2016 09:35:47 -0800
Message-ID: <1457112947.4044.133.camel@perches.com>
References: <1456360619-24390-1-git-send-email-troy.kisky@boundarydevices.com>
	 <1456360619-24390-14-git-send-email-troy.kisky@boundarydevices.com>
	 <VI1PR0401MB18552AB3E4128E412273B439FFBE0@VI1PR0401MB1855.eurprd04.prod.outlook.com>
	 <56D9B238.2040400@boundarydevices.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "fabio.estevam@freescale.com" <fabio.estevam@freescale.com>,
	"l.stach@pengutronix.de" <l.stach@pengutronix.de>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	"tremyfr@gmail.com" <tremyfr@gmail.com>,
	"linux@arm.linux.org.uk" <linux@arm.linux.org.uk>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"laci@boundarydevices.com" <laci@boundarydevices.com>,
	"shawnguo@kernel.org" <shawnguo@kernel.org>,
	"johannes@sipsolutions.net" <johannes@sipsolutions.net>,
	"stillcompiling@gmail.com" <stillcompiling@gmail.com>,
	"sergei.shtylyov@cogentembedded.com"
	<sergei.shtylyov@cogentembedded.com>,
	"arnd@arndb.de" <arnd@arndb.de>
To: Troy Kisky <troy.kisky@boundarydevices.com>,
	Fugang Duan <fugang.duan@nxp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"b38611@freescale.com" <b38611@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0161.hostedemail.com ([216.40.44.161]:54734 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758743AbcCDRf6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 12:35:58 -0500
In-Reply-To: <56D9B238.2040400@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-03-04 at 09:05 -0700, Troy Kisky wrote:
> On 3/4/2016 3:06 AM, Fugang Duan wrote:
> > From: Troy Kisky <troy.kisky@boundarydevices.com> Sent: Thursday, F=
ebruary 25, 2016 8:37 AM
[]
> > > Print the current interrupt flags and mask and the interrupt stat=
e during the last
> > > interrupt in fec_timeout.
[]
> > > diff --git a/drivers/net/ethernet/freescale/fec_main.c
[]
> > > @@ -1107,6 +1107,9 @@ fec_timeout(struct net_device *ndev)
> > > =A0	int i;
> > > =A0	uint events =3D 0;
> > >=20
> > > +	pr_err("%s: last=3D%x %x, mask %x\n", __func__, fep->last_ieven=
ts,
> > > +	=A0=A0=A0=A0=A0=A0=A0readl(fep->hwp + FEC_IEVENT), readl(fep->h=
wp + FEC_IMASK));
> > > +
> > pr_err() -> netdev_err()
> Sounds good

This seems like debugging information rather than
an error a user can do anything with and if there's
a timeout, how likely is it that the hardware is
hosed and this would=A0 repetitively and unnecessarily
fill up logs?

So maybe netdev_dbg and net_ratelimit() too.

	if (net_ratelimit()
		netdev_<level>(etc...)
