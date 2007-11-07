From: Simon Arlott <simon@fire.lp0.eu>
Subject: Re: [PATCH 02/05] ipv6: RFC4214 Support
Date: Wed, 07 Nov 2007 19:38:12 +0000
Message-ID: <47321424.1050407@simon.arlott.org.uk>
References: <200711071658.59478.netdev@axxeo.de><20071108.031214.124029872.yoshfuji@linux-ipv6.org><39C363776A4E8C4A94691D2BD9D1C9A1029EDBF2@XCH-NW-7V2.nw.nos.boeing.com> <20071108.034840.124896893.yoshfuji@linux-ipv6.org> <39C363776A4E8C4A94691D2BD9D1C9A1029EDBF4@XCH-NW-7V2.nw.nos.boeing.com> <47320B9B.6050301@simon.arlott.org.uk> <39C363776A4E8C4A94691D2BD9D1C9A1029EDBF9@XCH-NW-7V2.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>, netdev@axxeo.de, netdev@vger.kernel.org
To: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxima.lp0.eu ([85.158.45.36]:47035 "EHLO proxima.lp0.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753057AbXKGTiR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2007 14:38:17 -0500
In-Reply-To: <39C363776A4E8C4A94691D2BD9D1C9A1029EDBF9@XCH-NW-7V2.nw.nos.boeing.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/11/07 19:32, Templin, Fred L wrote:
> =20
>=20
>> -----Original Message-----
>> From: Simon Arlott [mailto:simon@fire.lp0.eu]=20
>> Sent: Wednesday, November 07, 2007 11:02 AM
>> To: Templin, Fred L
>> Cc: YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E; netdev=
@axxeo.de; netdev@vger.kernel.org
>> Subject: Re: [PATCH 02/05] ipv6: RFC4214 Support
>>=20
>> On 07/11/07 18:52, Templin, Fred L wrote:
>> >> > > > > +	eui[0] =3D 0;
>> >> > > > > +
>> >> > > > > +	/* Check for RFC3330 global address ranges */
>> >> > > > > +	if (((ipv4 >=3D 0x01000000) && (ipv4 < 0x0a000000)) ||
>> >> > > > > +	    ((ipv4 >=3D 0x0b000000) && (ipv4 < 0x7f000000)) ||
>> >> > > > > +	    ((ipv4 >=3D 0x80000000) && (ipv4 < 0xa9fe0000)) ||
>> >> > > > > +	    ((ipv4 >=3D 0xa9ff0000) && (ipv4 < 0xac100000)) ||
>> >> > > > > +	    ((ipv4 >=3D 0xac200000) && (ipv4 < 0xc0a80000)) ||
>> >> > > > > +	    ((ipv4 >=3D 0xc0a90000) && (ipv4 < 0xc6120000)) ||
>> >> > > > > +	    ((ipv4 >=3D 0xc6140000) && (ipv4 <=20
>> >> 0xe0000000))) eui[0] |=3D
>> >> > > > > 0x2;
>> >> I don't understand.
>> >>=20
>> >> For example, 1.0.0.11 is valid IPv4 global address.
>> >> In little-endian, this is not in the range of
>> >> 0x00000001 <=3D addr <=3D 0x0000000a (addr is 0x0b000001).
>> >=20
>> > Maybe it is I who did not understand. Can you suggest a=20
>> clean solution?
>>=20
>> ((ipv4 & htonl(0xFF000000)) =3D=3D htonl(0x0A000000)) etc.?
>=20
> I'm not sure this works when we consider disjoint ranges
> of globally-unique IP prefixes. Do you have a vision for
> how the entire conditional would look like?

You need to match RFC3330 addresses, not anything that isn't.

((ipv4 & htonl(0xFF000000)) =3D=3D htonl(0x0A000000))
|| ((ipv4 & htonl(0xFFFF0000)) =3D=3D htonl(0xC0A80000))
|| ((ipv4 & htonl(0xFF000000)) =3D=3D htonl(0x80000000))
etc.

--=20
Simon Arlott
