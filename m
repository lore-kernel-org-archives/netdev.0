From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: ip_summed setting for TCP pure-ACK packets
Date: Tue, 09 Nov 2010 16:24:48 +0000
Message-ID: <1289319889.2238.195.camel@achroite.uk.solarflarecom.com>
References: <1289234113.2222.20.camel@achroite.uk.solarflarecom.com>
	 <1289235366.15376.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	sf-linux-drivers <linux-net-drivers@solarflare.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:18361 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751223Ab0KIQYx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 11:24:53 -0500
In-Reply-To: <1289235366.15376.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-11-08 at 17:56 +0100, Eric Dumazet wrote:=20
> Le lundi 08 novembre 2010 =C3=A0 16:35 +0000, Ben Hutchings a =C3=A9c=
rit :
> > As we discussed at LPC:
> >=20
> > Current controllers handled by the sfc driver have a per-queue (rat=
her
> > than per-packet) option for checksum generation.  Currently pure-AC=
K
> > packets sent by TCP have ip_summed =3D=3D CHECKSUM_NONE and we must=
 send
> > them on hardware queues with checksum generation disabled.  To supp=
ort
> > this, we allocate 2 hardware queues per core TX queue.
> >=20
> > To reduce the risk of reordering (and possibly the number of hardwa=
re TX
> > queues required), it would be helpful for TCP to set ip_summed =3D=3D
> > CHECKSUM_PARTIAL on pure-ACK packets when the output device is know=
n to
> > support checksum generation.
> >=20
> > Ben.
> >=20
>=20
> Hmm
>=20
> Do you mean commit 2e8e18ef52e7dd1af0a3bd1 is not enough ?

It might well be... I must admit I hadn't thought to check whether this
issue had gone away.

Yes, that does the trick.  Sorry for wasting people's time on this.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


