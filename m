From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [RFC PATCH v2] Gemini: Gigabit ethernet driver
Date: Tue, 28 Dec 2010 12:45:20 +0100
Message-ID: <20101228114520.GA17774@rere.qmqm.pl>
References: <20101227103247.8D2E813909@rere.qmqm.pl> <alpine.LNX.2.00.1012271956260.8215@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: gemini-board-dev@lists.berlios.de, netdev@vger.kernel.org,
	Christoph Biedl <linux-kernel.bfrz@manchmal.in-ulm.de>
To: Hans Ulli Kroll <ulli.kroll@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:57245 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753093Ab0L1LpY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Dec 2010 06:45:24 -0500
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1012271956260.8215@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 27, 2010 at 08:21:44PM +0100, Hans Ulli Kroll wrote:
> On Mon, 27 Dec 2010, Micha=B3 Miros=B3aw wrote:
> > +		.dis_tx =3D 1,
> > +		.dis_rx =3D 1,
> > +		.max_len =3D 2,	/* magic; 512 << max_len? */
> > +		.ipv4_rx_chksum =3D 1,
> > +		.ipv6_rx_chksum =3D 1,
>=20
> This is what I found in some netbsd code for maxlen
>=20
> #define	CONFIG0_MAXLEN_MASK			__BITS(8,10)
> #define	CONFIG0_MAXLEN_GET(x)			(((x) >> 8) &=20
> CONFIG0_MAXLEN_MASK)
> #define	CONFIG0_MAXLEN(x)			(((x) &=20
> CONFIG0_MAXLEN_MASK) << 8)
> #define	CONFIG0_MAXLEN_1536			0
> #define	CONFIG0_MAXLEN_1518			1
> #define	CONFIG0_MAXLEN_1522			2
> #define	CONFIG0_MAXLEN_1548			3
> #define	CONFIG0_MAXLEN_JUMBO			4
>=20
> spec. for the SL3616 says jumbo is 9k frames, but i didn't proved thi=
s.

This is what I got after quick testing:

max_len rx_max
0       1536
1       1518
2       1522
3       1542
4       9212
5       10236
6       1518
7       1518

rx_max is total packet's length (MAC header + (VLAN) + payload).
=20
Best Regards,
Micha=B3 Miros=B3aw
