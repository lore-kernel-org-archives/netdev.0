From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC patch net/next] net: Hoist assigns from if?
Date: Tue, 15 Jun 2010 07:42:06 +0200
Message-ID: <1276580526.30434.330.camel@edumazet-laptop>
References: <1276561234.4897.38.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:62846 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750772Ab0FOFmK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 01:42:10 -0400
Received: by wwb18 with SMTP id 18so4445906wwb.19
        for <netdev@vger.kernel.org>; Mon, 14 Jun 2010 22:42:09 -0700 (PDT)
In-Reply-To: <1276561234.4897.38.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 14 juin 2010 =C3=A0 17:20 -0700, Joe Perches a =C3=A9crit :
> Awhile back I posted a script to reformat source code,
> similar to Lindent, but able to select in a piecemeal
> manner what source code style to convert.
>=20
> http://lkml.org/lkml/2010/3/24/447
>=20
> One of the options is to convert code from:
> 	if ((err =3D function(args)) !=3D NULL) {
> to:
> 	err =3D function(args);
> 	if (err !=3D NULL) {
>=20
> I ran this script against net/ and get this result:
>=20
> $ grep -rPl --include=3D*.[ch] "\bif\s*\(\s*\(" net/ | \
>   grep -v netfilter | \
>   xargs ./scripts/cvt_kernel_style.pl -o -convert=3Dhoist_assigns_fro=
m_if=20
>=20
> and after a little cleanup, compilation verification, etc
> I get the diffstat below.  Should I post the actual patch?
>=20

I'll answer for myself, but wait for David answer ;)

Quite honestly, this kind of patch sucks, because it pollutes 'git
blame' output. Its hard to point out the origin of a particular
bug/code, and we have to spend precious time playing with complex git
commands to go over cleanup patches.

Maybe its possible to mark a patch with a 'cleanups only' git qualifier
that can be ignored by 'git blame' ?

If not, that would be a nice git improvement to work on.

Alternatively, you could change real old stuff only (marked as the
original commit from Linus (1da177e4c3f4), creation of the known
universe back in 2005.



