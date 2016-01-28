From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next 08/40] net: fec: move cbd_bufaddr assignment
 closer to the mapping function
Date: Thu, 28 Jan 2016 23:14:19 +0100
Message-ID: <1454019259.2332.17.camel@sipsolutions.net>
References: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
	 <1454016364-30985-9-git-send-email-troy.kisky@boundarydevices.com>
	 <1725152.bhtFKTSjnb@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Troy Kisky <troy.kisky@boundarydevices.com>,
	netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com,
	fabio.estevam@freescale.com, andrew@lunn.ch,
	linux@arm.linux.org.uk, laci@boundarydevices.com,
	l.stach@pengutronix.de, shawnguo@kernel.org, tremyfr@gmail.com
To: Arnd Bergmann <arnd@arndb.de>, linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:57458 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750732AbcA1WO0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jan 2016 17:14:26 -0500
In-Reply-To: <1725152.bhtFKTSjnb@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-01-28 at 23:02 +0100, Arnd Bergmann wrote:
> On Thursday 28 January 2016 14:25:32 Troy Kisky wrote:
> > Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
> > ---
> > =C2=A0drivers/net/ethernet/freescale/fec_main.c | 4 ++--
> > =C2=A01 file changed, 2 insertions(+), 2 deletions(-)
>=20
> [note: missing changelog?]
>=20
> > diff --git a/drivers/net/ethernet/freescale/fec_main.c
> > b/drivers/net/ethernet/freescale/fec_main.c
> > index b87f80d..15a93f90 100644
> > --- a/drivers/net/ethernet/freescale/fec_main.c
> > +++ b/drivers/net/ethernet/freescale/fec_main.c
> > @@ -476,6 +476,8 @@ static int fec_enet_txq_submit_skb(struct
> > fec_enet_priv_tx_q *txq,
> > =C2=A0				estatus |=3D BD_ENET_TX_TS;
> > =C2=A0		}
> > =C2=A0	}
> > +	bdp->cbd_bufaddr =3D addr;
> > +	bdp->cbd_datlen =3D buflen;
> > =C2=A0
> > =C2=A0	if (fep->bufdesc_ex) {
> > =C2=A0
> > @@ -499,8 +501,6 @@ static int fec_enet_txq_submit_skb(struct
> > fec_enet_priv_tx_q *txq,
> > =C2=A0	/* Save skb pointer */
> > =C2=A0	txq->tx_skbuff[index] =3D skb;
> > =C2=A0
> > -	bdp->cbd_datlen =3D buflen;
> > -	bdp->cbd_bufaddr =3D addr;
> > =C2=A0	/* Make sure the updates to rest of the descriptor are
> > performed before
> > =C2=A0	=C2=A0* transferring ownership.
> > =C2=A0	=C2=A0*/
> >=20
>=20
> This patch and others in the series conflicts with the bugfix "net:
> fec: make driver endian-safe" that Johannes sent this week. Can you
> include his fix in your series and ensure that all descriptor
> accesses are done in an endian-safe way?
>=20

My fixes are already in net.git, so you should base on a current
net.git or on net-next.git after net.git is merged there (which davem
usually does after Linus merges from him, IIRC)

johannes
