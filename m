From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next 3/3] macsec: introduce IEEE 802.1AE driver
Date: Wed, 09 Mar 2016 12:24:20 +0100
Message-ID: <1457522660.2042.9.camel@sipsolutions.net>
References: <cover.1456937772.git.sd@queasysnail.net>
	 <d7145f6037142ea5134be0402e014a9c72f7b8d4.1456937772.git.sd@queasysnail.net>
	 <1457468033.24270.38.camel@sipsolutions.net>
	 <20160309105614.GA24911@bistromath.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Paolo Abeni <pabeni@redhat.com>, stephen@networkplumber.org
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:48679 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752422AbcCILYY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Mar 2016 06:24:24 -0500
In-Reply-To: <20160309105614.GA24911@bistromath.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Thanks for the comments.

> > > +struct gcm_iv {
> > > +	union {
> > > +		u8 secure_channel_id[8];
> > > +		sci_t sci;
> > > +	};
> > > +	__be32 pn;
> > > +};
> >=20
> > Should this be __packed?
>=20
> I think that's not necessary here.

Yeah, there's probably no way a compiler could ever do something with
it that's not the same as packed, but it seems to me that just out of
convention structs that have some wire-format meaning should usually be
__packed. But it's your call. I'm not even entirely sure it has a wire-
format or similar meaning, although the name indicates it gets used
into the encryption and must be exactly these 12 octets.

> > That way, you have the same policy for everything and also don't
> > have
> > to play tricks with the aliasing since the top-level attributes
> > actually exist now, coming from the same namespace & policy.
>=20
> That's a good idea, I'll have a look today.
> I don't really like the aliasing games I have to play, but I'd like
> to
> keep the RXSC attributes separate from the SA attributes, I think it
> looks cleaner (the first RFC had everything in the same policy:
> http://www.spinics.net/lists/netdev/msg358152.html).
>=20

Ah, I see. Keeping it separate makes sense, but you can still achieve
that like this:

msg =3D [ifindex -> 7,
=C2=A0 =C2=A0 =C2=A0 =C2=A0rxsc -> [ sci -> 2, ...
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0],
=C2=A0 =C2=A0 =C2=A0 =C2=A0...
=C2=A0 =C2=A0 =C2=A0 ]

with nested data. I'd also do the same for the stats and a whole bunch
of others too, I guess. I tend to imagine it as a kind of "dict of
dicts" (the message with nested).

Thanks,
johannes
