From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: skb header allocation
Date: Tue, 25 Aug 2009 20:15:14 -0700
Message-ID: <20090825201514.0dd143ad@nehalam>
References: <17cd85320908252004r31874732n9e06921d6eae4ad7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Chris Ross <chris@compilednetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38217 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756586AbZHZDPS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 23:15:18 -0400
In-Reply-To: <17cd85320908252004r31874732n9e06921d6eae4ad7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 25 Aug 2009 22:04:10 -0500
Chris Ross <chris@compilednetworks.com> wrote:

> I have a network driver that acts as a Ethernet device and builds up =
a
> series of outer headers on skb(s) it receives from upper layers. I am
> currently using the technique that is in ipip.c to ensure I have
> enough room to add my header ...
>=20
> if (skb_headroom(skb) < some_value || skb_shared(skb) ||
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ((skb_cloned(skb) &&=
 !skb_clone_writable(skb, 0))))
> =C2=A0=C2=A0 {
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if ((skb2 =3D skb_realloc_headroom(skb=
, some_value)) =3D=3D NULL)
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return -1;
>=20
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 dev_kfree_skb(skb);
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 skb =3D skb2;
> =C2=A0=C2=A0 }
>=20
> Is this the best practice for a high bandwidth scenario?

Define a value of dev->hard_header_len that adds space for what you nee=
d.
Use skb_cow_head(skb, headroom) before touching skb header.
