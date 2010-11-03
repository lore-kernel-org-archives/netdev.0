From: Micha?? Miros??aw <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH 2/4] Ethtool: convert get_sg/set_sg calls to
	hw_features flag
Date: Wed, 3 Nov 2010 23:29:10 +0100
Message-ID: <20101103222910.GA24320@rere.qmqm.pl>
References: <cover.1288496404.git.mirq-linux@rere.qmqm.pl> <9d89236b6e4ff8c66937fbd7d8ce76602e680c5b.1288496404.git.mirq-linux@rere.qmqm.pl> <20101102022438.GA4243@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Rasesh Mody <rmody@brocade.com>,
	Debashis Dutt <ddutt@brocade.com>,
	Kristoffer Glembo <kristoffer@gaisler.com>,
	"linux-driver@qlogic.com" <linux-driver@qlogic.com>,
	"linux-net-drivers@solarflare.com" <linux-net-drivers@solarflare.com>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:54400 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752965Ab0KCW3M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Nov 2010 18:29:12 -0400
Content-Disposition: inline
In-Reply-To: <20101102022438.GA4243@mcarlson.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 01, 2010 at 07:24:38PM -0700, Matt Carlson wrote:
> On Fri, Oct 29, 2010 at 09:28:26PM -0700, Micha?? Miros??aw wrote:
> > diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> > index 30ccbb6..b07e2d1 100644
> > --- a/drivers/net/tg3.c
> > +++ b/drivers/net/tg3.c
> > @@ -11306,7 +11306,6 @@ static const struct ethtool_ops tg3_ethtool=
_ops =3D {
> >         .get_rx_csum            =3D tg3_get_rx_csum,
> >         .set_rx_csum            =3D tg3_set_rx_csum,
> >         .set_tx_csum            =3D tg3_set_tx_csum,
> > -       .set_sg                 =3D ethtool_op_set_sg,
> >         .set_tso                =3D tg3_set_tso,
> >         .self_test              =3D tg3_self_test,
> >         .get_strings            =3D tg3_get_strings,
> > @@ -14681,6 +14680,7 @@ static int __devinit tg3_init_one(struct pc=
i_dev *pdev,
> >         tp->rx_pending =3D TG3_DEF_RX_RING_PENDING;
> >         tp->rx_jumbo_pending =3D TG3_DEF_RX_JUMBO_RING_PENDING;
> >=20
> > +       dev->hw_features |=3D NETIF_F_SG;
> Scatter-gather should not be enabled if TG3_FLAG_BROKEN_CHECKSUMS is =
set.  I
> would do the following instead:
>=20
> 	if (!(tp->tg3_flags & TG3_FLAG_BROKEN_CHECKSUMS))
> 		dev->hw_features |=3D NETIF_F_SG;
>=20
> TG3_FLAG_BROKEN_CHECKSUMS is set in tg3_get_invariants(), so this cod=
e
> would need to be placed later than that function call.

This bug is there now, so I'll queue this as all other hints of existen=
t
bugs that this patch series "uncovers".

Best Regards,
Micha=B3 Miros=B3aw
