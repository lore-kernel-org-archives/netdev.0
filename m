From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Gigabit Ethernet driver of Topcliff PCH
Date: Thu, 02 Sep 2010 15:40:47 +0200
Message-ID: <1283434847.2454.726.camel@edumazet-laptop>
References: <4C763A67.5040107@dsn.okisemi.com>
	 <4C7D0E7A.5060309@dsn.okisemi.com>
	 <1283266263.2550.106.camel@edumazet-laptop>
	 <000a01cb4a9b$e8d6ab00$66f8800a@maildom.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Sam Ravnborg <sam@ravnborg.org>, Joe Perches <joe@perches.com>,
	LKML <linux-kernel@vger.kernel.org>,
	ML netdev <netdev@vger.kernel.org>,
	Greg Rose <gregory.v.rose@intel.com>,
	Maxime Bizon <mbizon@freebox.fr>,
	Kristoffer Glembo <kristoffer@gaisler.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	John Linn <john.linn@xilinx.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	MeeGo <meego-dev@meego.com>, "Wang, Qi" <qi.wang@intel.com>,
	"Wang, Yong Y" <yong.y.wang@intel.com>,
	Andrew <andrew.chih.howe.khor@intel.com>,
	Intel OTC <joel.clark@intel.com>,
	"Foster, Margie" <margie.foster@intel.com>,
	Toshiharu Okada <okada533@dsn.okisemi.com>,
	Tomoya Morinaga <morinaga526@dsn.okisemi.com>,
	Takahiro Shimizu <shimizu394@dsn.okisemi.com>
To: Masayuki Ohtake <masa-korg@dsn.okisemi.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <000a01cb4a9b$e8d6ab00$66f8800a@maildom.okisemi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 02 septembre 2010 =C3=A0 21:39 +0900, Masayuki Ohtake a =C3=A9=
crit :
> Hi Eric
>=20
> Thank you for your comments.
>=20
> > I find hard to believe this driver needs to copy all outgoing frame=
s on
> > pre-allocated skbs.
> >
> > +       /* [Header:14][payload] ---> [Header:14][paddong:2][payload=
]    */
> > +       memcpy(tmp_skb->data, skb->data, ETH_HLEN);
> > +       tmp_skb->data[ETH_HLEN] =3D 0x00;
> > +       tmp_skb->data[ETH_HLEN + 1] =3D 0x00;
> > +       tmp_skb->len =3D skb->len;
> > +       memcpy(&tmp_skb->data[ETH_HLEN + 2], &skb->data[ETH_HLEN],
> > +              (skb->len - ETH_HLEN));
> > +       buffer_info->kernel_skb =3D skb;
> > +       skb =3D tmp_skb;
> >
> > Whats the deal here please ?
>=20
> This processing depends on hardware specification.
>=20
> At the time of transmission.
> Hardware accepts a packet in the following format.
>   [Header: 14octet] + [padding: 2octet] + [payload]
>   Also, it is necessary to align the head of a [Header: 14octet] at 6=
4byte.
>=20
> In my knowledge, SKB received by kernel are the following format.
>   [padding: 2octet] + [Header:14octet] + [payload]
>   Also, The head of [payload] has aligned at 16 byte.
>=20
> So, it has adjusted with the format of hardware by a copy.

The two bytes padding can be handled by network stack, if you
force in your setup phase :
	dev->hard_header_len =3D ETH_HLEN + 2;

then, you can do a single memcpy:

memcpy(tmp_skb->data, skb->data, skb->len);

About the 64 byte alignement, it might be a bit more complex :)
