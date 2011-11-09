From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] neigh: replace unres_qlen by unres_qlen_bytes
Date: Wed, 09 Nov 2011 08:55:25 +0100
Message-ID: <1320825325.26025.51.camel@edumazet-laptop>
References: <1320792301.26025.21.camel@edumazet-laptop>
	 <20111108.174820.558780148839093199.davem@davemloft.net>
	 <1320797656.26025.43.camel@edumazet-laptop>
	 <20111109.001843.1753987502002673227.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:45855 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751427Ab1KIHza (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2011 02:55:30 -0500
Received: by wyh15 with SMTP id 15so1320151wyh.19
        for <netdev@vger.kernel.org>; Tue, 08 Nov 2011 23:55:28 -0800 (PST)
In-Reply-To: <20111109.001843.1753987502002673227.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 09 novembre 2011 =C3=A0 00:18 -0500, David Miller a =C3=A9c=
rit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 09 Nov 2011 01:14:16 +0100
>=20
> > unres_qlen is the number of frames we are able to queue per unresol=
ved
> > neighbour. Its default value (3) was never changed and is responsib=
le
> > for strange drops, especially if IP fragments are used, or multiple
> > sessions start in parallel. TCP initial congestion window is now bi=
gger
> > than 3.
>=20
> BTW, it has been observed in practice that if a long living connectio=
n
> suddently sends a burst of traffic after a very long idle period
> (hitting ARP expiry) or something invalidates the ARP entry in use, w=
e
> will drop frames.  Because even if the ARP reply comes "fast" it's
> never quick enough to beat the burst of frames.
>=20
> And if this happens in a scenerio where such lost packets potentially
> mean lost money...

I'll submit a more complete patch, including a fallback support of
unres_qlen, and one missing initializer in nl_ntbl_parm_policy[]

+	[NDTPA_QUEUE_LENBYTES]          =3D { .type =3D NLA_U32 },

=20
