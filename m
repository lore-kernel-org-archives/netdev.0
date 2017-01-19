From: Doug Ledford <dledford@redhat.com>
Subject: Re: [pull request][for-next] Mellanox mlx5 Reorganize core driver
 directory layout
Date: Thu, 19 Jan 2017 01:32:38 -0500
Message-ID: <1484807558.2406.85.camel@redhat.com>
References: <CALzJLG--ZRVk0Zy+6UaGCWbOhki+PZnkmrh9rjojU1ZDm_5Y6w@mail.gmail.com>
         <20170118.123207.53777509111948450.davem@davemloft.net>
         <CALx6S36p2g8EP48R+nWQu9tHtS5h8eKo7bj7rskmSMxCU36KXA@mail.gmail.com>
         <20170119.003832.1262212358977773325.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
        protocol="application/pgp-signature"; boundary="=-WtnqmtCzakocxFLtT5ZQ"
Cc: saeedm@dev.mellanox.co.il, saeedm@mellanox.com,
        netdev@vger.kernel.org, linux-rdma@vger.kernel.org, leon@kernel.org
To: David Miller <davem@davemloft.net>, tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43038 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750977AbdASGcl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Jan 2017 01:32:41 -0500
In-Reply-To: <20170119.003832.1262212358977773325.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-WtnqmtCzakocxFLtT5ZQ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2017-01-19 at 00:38 -0500, David Miller wrote:
> From: Tom Herbert <tom@herbertland.com>
> Date: Wed, 18 Jan 2017 21:22:53 -0800
>=20
> > In principle I=C2=A0 agree, but as I previously wrote backporting this
> > driver is already a bear. We need to do something here as this is
> > quickly approaching being infeasible to backport. Even if we don't
> > restructure the directories I'd still like to see some effort
> towards
> > feature modularization and isolation.
>=20
> There simply is a lot changing all the time, no restructuring is
> going
> to reduce that.=C2=A0 The driver simply gets a lot of churn.
>=20
> Backporting such things through a bunch of file and/or directory
> renames is seriously nothing but asking for more punishment.
>=20
> That's why I am against it.

So, I spent the better part of two years dealing with this after the
drivers/net/mellanox drivers/net/ethernet/mellanox rename, so I'll
chime in. =C2=A0Especially since Tom's problem directly relates to the
issues I dealt with when trying to take the latest Mellanox driver and
shoe-horn it into a Red Hat kernel that didn't have the same net core
(I had to pick and choose which mlx patches to take in order to work
with our existing net core, and the files were renamed on top of that).

If you rename a file from place A to place B and keep the file the
same, then a git backport can be done using techniques such as git
cherry-pick with the --follow option enabled. =C2=A0It's slow, but works.

But that's not what you've brought up. =C2=A0You brought up continuing the
rename to go further and split code out into files based upon features.
=C2=A0While git cherry-pick can follow renames mostly automatically, it can
not follow refactors. =C2=A0If they move the tcflower stuff out to a file o=
n
its own, and you then attempt to backport some fix that touches the
tcflower support in the new location while you have not taken the move
patch, you will find that git will be totally stymied.

What you have now is not perfect and you have to sort through commits
to get the right ones and skip the ones you can't support, but things
mostly apply except when context diffs break issues. =C2=A0With the refacto=
r
and separation you speak of, git will be totally unable to help and you
will have to manually edit patches to point at new files or hand edit
the files to apply the patches.

I understand the desire for order instead of chaos, but it really will
not help. =C2=A0Bringing patches from the new order back to the old chaos
will be so much harder than just continuing as things are that you will
silently curse the change shortly after it is made.

--=20
Doug Ledford <dledford@redhat.com>
=C2=A0 =C2=A0 GPG KeyID: B826A3330E572FDD
=C2=A0 =C2=A0
Key fingerprint =3D AE6B 1BDA 122B 23B4 265B =C2=A01274 B826 A333 0E57 2FDD

--=-WtnqmtCzakocxFLtT5ZQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCAAGBQJYgF2GAAoJELgmozMOVy/dxG8QAKi1omV5w78lKzw8Wol0yiFy
46g7XgoJGG2EIkmA5N2pDencKpoew/3CQUJAo6fgKWqrLOfSKcA8a3FffXcIGcK5
NWO/OqsJxa3xMTAEwd+O5sDwjHt47tZvwFkSSzoMBzdIh73qnXZ+3ziXaBYFvNNF
umDJCEj9lYAwy00YeB98znySjv9lmO8tuFwpDe7pdJBIhwJSMm/ENmz0DClJ2K4p
LAMEbleumnUDWz5hx37ksJ0PMsMw3Y3KkLhRFMWiC7BBEn/YmgA4QUryFAqH4I6z
Wo4hl+tgOkt0g62CuALzbLHsHgbbjqoUaqzVayw0YCBomJnbJlTrWint3lDygCbw
UPLUxrYHPyCVOrl7Df3keYucQa7q0wWfpBd+7YnGHgpYnlPlOaPSIWpnQ7vOi2nE
p3aDMG9xODF2ufgHH9L5XF2WM0tiPlVI2fTd8qeFgqn8COGyNrPGuDq8me16jK2k
KhAAe0WNQj4Vc2CAlkW9X8mm3mdHJALCmUcEh20dlNsJ87+7vAYOyg04KbvIlyAp
YeTmYfFHB3Eh4zBlrqCijvZEckHMrLnypppBzqBGqU+rI6sRW3EYt6QyOB+SVKA/
RG6f8kio/2V3Zz7i1DAvj8c2qymTko3AchZl15tqWNF3W/PgVzwDgrg3dMFz602I
TU13hXLZwnGzxi40kTzG
=ZAmW
-----END PGP SIGNATURE-----

--=-WtnqmtCzakocxFLtT5ZQ--
