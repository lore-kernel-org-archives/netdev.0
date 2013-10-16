From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] X.25: Fix address field length calculation
Date: Wed, 16 Oct 2013 09:56:18 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B738F@saturn3.aculab.com>
References: <525D5131.9070007@datus.com> <1381858190.22110.25.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <andrew.hendry@gmail.com>, <davem@davemloft.net>,
	<linux-x25@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: "Joe Perches" <joe@perches.com>,
	=?Windows-1252?Q?Kelleter=2C=22_G=FCnther?= <GKelleter@datus.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <1381858190.22110.25.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Tue, 2013-10-15 at 14:29 +0000, Kelleter, G=FCnther wrote:
> > Addresses are BCD encoded, not ASCII. x25_addr_ntoa got it right.
> []
> > Wrong length calculation leads to rejection of CALL ACCEPT packets.
> []
> > diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
> []
> > @@ -98,7 +98,7 @@ int x25_parse_address_block(struct sk_buff *skb,
> >  	}
> >   	len =3D *skb->data;
> > -	needed =3D 1 + (len >> 4) + (len & 0x0f);
> > +	needed =3D 1 + ((len >> 4) + (len & 0x0f) + 1) / 2;
>=20
> This calculation looks odd.

Looks correct to me...
In X.25 the lengths (in digits) of the called and calling addresses
are encoded in the high and low nibbles of one byte and then
followed by both addresses with a digit in each nibble.
If the length of the first address is odd, the second one
isn't byte aligned.

	David
