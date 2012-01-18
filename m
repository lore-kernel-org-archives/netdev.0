From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bugzilla 42595
Date: Wed, 18 Jan 2012 11:58:31 +0100
Message-ID: <1326884311.2316.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1326817699.2259.32.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4F15D417.4050005@fud.no> <1326843827.2606.35.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Tore Anderson <tore@fud.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:45136 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752984Ab2ARK6g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2012 05:58:36 -0500
Received: by vcbfo1 with SMTP id fo1so2546355vcb.19
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2012 02:58:35 -0800 (PST)
In-Reply-To: <1326843827.2606.35.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 18 janvier 2012 =C3=A0 00:43 +0100, Eric Dumazet a =C3=A9cr=
it :
> Le mardi 17 janvier 2012 =C3=A0 21:03 +0100, Tore Anderson a =C3=A9cr=
it :
>=20
> >=20
> > 3) There seems to be a bug related to generating the TCP checksum o=
f
> > SYN/ACK packets to destinations with the allfrag features set. I ju=
st
> > submitted a bug report about this:
> >=20
> > https://bugzilla.kernel.org/show_bug.cgi?id=3D42595
> >=20
> > This makes the allfrag feature pretty much useless for me, as I can=
 only
> > successfully establish a single TCP session from a client behind a =
<1280
> > MTU link for the entire lifetime of the routing cache entry.
> >=20
>=20
> It seems we dont handle skb ip_summed CHECKSUM_PARTIAL=20
> in ip6_fragment() slow_path


and many drivers dont handle the presence of a frag header.

if (ipv6_hdr(skb)->nexthdr =3D=3D IPPROTO_TCP)

I suspect we'll have to compute the checksum in software...
