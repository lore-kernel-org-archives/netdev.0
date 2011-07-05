From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH 2/2] packet: Add fanout support.
Date: Tue, 05 Jul 2011 18:16:17 +0200
Message-ID: <1309882577.2271.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20110704.212014.236340473910292460.davem@davemloft.net>
	 <1309846875.2720.43.camel@edumazet-laptop>  <4E12B5A6.2020802@inliniac.net>
	 <1309849214.2720.45.camel@edumazet-laptop>
	 <D3F292ADF945FB49B35E96C94C2061B91257D61B@nsmail.netscout.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Victor Julien <victor@inliniac.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: "Loke, Chetan" <Chetan.Loke@netscout.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:37839 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753732Ab1GEQQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 12:16:31 -0400
Received: by wwe5 with SMTP id 5so6098904wwe.1
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2011 09:16:29 -0700 (PDT)
In-Reply-To: <D3F292ADF945FB49B35E96C94C2061B91257D61B@nsmail.netscout.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 05 juillet 2011 =C3=A0 12:03 -0400, Loke, Chetan a =C3=A9crit =
:
> > -----Original Message-----
> > From: netdev-owner@vger.kernel.org [mailto:netdev-
> > owner@vger.kernel.org] On Behalf Of Eric Dumazet
> > Sent: July 05, 2011 3:00 AM
> > To: Victor Julien
> > Cc: David Miller; netdev@vger.kernel.org
> > Subject: Re: [PATCH 2/2] packet: Add fanout support.
> >=20
> > Le mardi 05 juillet 2011 =C3=A0 08:56 +0200, Victor Julien a =C3=A9=
crit :
> >=20
> > > Is this still also true for IP fragments?
> > >
> >=20
> > This point was already raised. IP fragments have rxhash =3D 0, obvi=
ously,
> > since we dont have full information (source / destination ports for
> > example)
>=20
> Can we not do something like:
>=20
> a =3D src_ip_addr;
> b =3D dst_ip_addr;
>=20
> if (ip_is_fragment(ip_hdr(skb)))
> 	c =3D ip_hdr->id;
> else
> 	c =3D src_port | dest_port ; /* port_32 etc - Similar to what we hav=
e today */
>=20
> /* swap a/b etc */
> jhash3_words(a,b,c);
>=20
>=20
>=20

Sure, but non fragmented packets will then get a different rxhash.

Remember, goal is that _all_ packets of a given flow end in same queue.



