From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] net: add driver for the NIC on Cell Blades
Date: Wed, 29 Jun 2005 02:38:58 +0200
Message-ID: <200506290238.59231.arnd@arndb.de>
References: <200506281528.08834.arnd@arndb.de>
	<1119966799.3175.32.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Utz Bacher <utz.bacher@de.ibm.com>, linuxppc64-dev@ozlabs.org,
	Jeff Garzik <jgarzik@pobox.com>, Jens Osterkamp <Jens.Osterkamp@de.ibm.com>
Return-path: <linuxppc64-dev-bounces@ozlabs.org>
To: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <1119966799.3175.32.camel@laptopd505.fenrus.org>
Content-Disposition: inline
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc64-dev>
List-Post: <mailto:linuxppc64-dev@ozlabs.org>
List-Help: <mailto:linuxppc64-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc64-dev-bounces@ozlabs.org
Errors-To: linuxppc64-dev-bounces@ozlabs.org
List-Id: netdev.vger.kernel.org

On Dinsdag 28 Juni 2005 15:53, Arjan van de Ven wrote:
>=20
> > +static void
> > +spider_net_rx_irq_off(struct spider_net_card *card)
> > +{
> > + =A0 =A0 =A0 u32 regvalue;
> > + =A0 =A0 =A0 unsigned long flags;
> > +
> > + =A0 =A0 =A0 spin_lock_irqsave(&card->intmask_lock, flags);
> > + =A0 =A0 =A0 regvalue =3D spider_net_read_reg(card, SPIDER_NET_GHIINT0=
MSK);
> > + =A0 =A0 =A0 regvalue &=3D ~SPIDER_NET_RXINT;
> > + =A0 =A0 =A0 spider_net_write_reg(card, SPIDER_NET_GHIINT0MSK, regvalu=
e);
> > + =A0 =A0 =A0 spin_unlock_irqrestore(&card->intmask_lock, flags);
> > +}
>=20
> I think you have a PCI posting bug here....

Could you be more specific? My guess would be that the 'sync' in writel
takes care of this. Should there be an extra mmiowb() in here or are
you referring to some other problem?

	Arnd <><
