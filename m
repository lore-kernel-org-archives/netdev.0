From: <mika.penttila@kolumbus.fi>
Subject: Re: Re: [PATCH] Fix checksum bug for multicast/broadcast packets on postrouting hook
Date: Mon, 16 Feb 2004 16:14:47 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040216141448.HGON15980.fep20-app.kolumbus.fi@mta.imail.kolumbus.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@redhat.com>, Harald Welte <laforge@netfilter.org>,
        <netdev@oss.sgi.com>, Stephen Smalley <sds@epoch.ncsc.mil>
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>=20
> On Mon, 16 Feb 2004, Mika Penttil=E4 wrote:
>=20
> > James Morris wrote:
> >=20
> > >No, it's not needed by all callers, and is just a does-one-thing hel=
per=20
> > >function.
> > >
> > >
> > It is needed for cloned skbs, so check for this should go in=20
> > skb_checksum_help().
>=20
> No, there is no need to bloat a simple helper function out with this=20
> (and then need to handle OOM internally etc.), and it is not appropriat=
e=20
> for all callers.
>=20
> - James

Copy is always required whenever skb_cloned() is true. skb_checksum_help(=
) modifies the shared protocol checksum but leaves ip_summed to CHECKSUM_=
HW in other clones.

--Mika
