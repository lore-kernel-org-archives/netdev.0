From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: RFC: MTU for serving NFS on Infiniband
Date: Wed, 25 Aug 2010 07:54:58 +0200
Message-ID: <1282715698.2467.681.camel@edumazet-laptop>
References: <alpine.LNX.2.00.1008230842290.9325@abcyxhiz.aict.ualberta.ca>
	 <20100823080543.319143e3@nehalam>
	 <alpine.WNT.2.00.1008240856170.2000@cluij.ucs.ualberta.ca>
	 <1282672647.2302.15.camel@achroite.uk.solarflarecom.com>
	 <alpine.WNT.2.00.1008241338470.1132@cluij.ucs.ualberta.ca>
	 <1282688441.22839.34.camel@localhost>  <20100824153920.63360072@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Marc Aurele La France <tsi@ualberta.ca>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:55105 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751742Ab0HYFzF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 01:55:05 -0400
In-Reply-To: <20100824153920.63360072@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 24 ao=C3=BBt 2010 =C3=A0 15:39 -0700, Stephen Hemminger a =C3=A9=
crit :

> IF NFS server is smart enough to generate:
>    Header (skb) + one or more pages in fragment list
> then IP fragmentation could do fragmentation by allocating
> new headers skb (small) and assigning the same pages to
> multiple skb's using page ref count.
>=20
> It obviously isn't working that way.
>=20

It is, but ip_append_data() is allocating a huge head if MTU is huge.

NFS is trying to build paged skb, to avoid order-X allocations (X > 0)

> The whole problem is moot because NFS over UDP has known data corrupt=
ion
> issues in the face of packet loss.  The sequence number of the IP fra=
gment
> can easily wrap around causing old data to be grouped with new data a=
nd
> the UDP checksum is so weak that the resulting UDP packet will be con=
sumed by the NFS
> client ans passed to the user application as corrupted disk block.
>=20
> DON'T USE NFS OVER UDP!

But Marc point is using a big MTU, so that no IP fragmentation is
needed.

All UDP applications using MSG_MORE will hit the order-2 allocations if
MTU=3D9000 for example...



