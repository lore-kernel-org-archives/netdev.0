From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] [TCP]: Process DSACKs that reside within a SACK
 block
Date: Wed, 31 Oct 2007 02:51:04 -0700 (PDT)
Message-ID: <20071031.025104.37987469.davem@davemloft.net>
References: <Pine.LNX.4.64.0710311136200.16864@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43075
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754698AbXJaJvE convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2007 05:51:04 -0400
In-Reply-To: <Pine.LNX.4.64.0710311136200.16864@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Wed, 31 Oct 2007 11:48:31 +0200 (EET)

> DSACK inside another SACK block were missed if start_seq of DSACK
> was larger than SACK block's because sorting prioritizes full
> processing of the SACK block before DSACK. After SACK block
> sorting situation is like this:
>=20
>              SSSSSSSSS
>                   D
>                         SSSSSS
>                                SSSSSSS
>=20
> Because write_queue is walked in-order, when the first SACK block
> has been processed, TCP is already past the skb for which the
> DSACK arrived and we haven't taught it to backtrack (nor should
> we), so TCP just continues processing by going to the next SACK
> block after the DSACK (if any).
>=20
> Whenever such DSACK is present, do an embedded checking during
> the previous SACK block.
>=20
> If the DSACK is below snd_una, there won't be overlapping SACK
> block, and thus no problem in that case. Also if start_seq of
> the DSACK is equal to the actual block, it will be processed
> first.
>=20
> Tested this by using netem to duplicate 15% of packets, and
> by printing SACK block when found_dup_sack is true and the=20
> selected skb in the dup_sack =3D 1 branch (if taken):
>=20
>   SACK block 0: 4344-5792 (relative to snd_una 2019137317)
>   SACK block 1: 4344-5792 (relative to snd_una 2019137317)=20
>=20
> equal start seqnos =3D> next_dup =3D 0, dup_sack =3D 1 won't occur...
>=20
>   SACK block 0: 5792-7240 (relative to snd_una 2019214061)
>   SACK block 1: 2896-7240 (relative to snd_una 2019214061)
>   DSACK skb match 5792-7240 (relative to snd_una)
>=20
> ...and next_dup =3D 1 case (after the not shown start_seq sort),
> went to dup_sack =3D 1 branch.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

I will queue this bug fix up, thanks Ilpo!

And thanks for all of the testing information, it helps review
enormously.
