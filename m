From: Pavel Machek <pavel@ucw.cz>
Subject: Re: stmmac: turn coalescing / NAPI off in stmmac
Date: Fri, 2 Dec 2016 11:42:38 +0100
Message-ID: <20161202104238.GA31172@amd>
References: <20161124085506.GA25007@amd>
 <20161124.110416.198867271899443489.davem@davemloft.net>
 <20161130114431.GB14296@amd>
 <20161201.152303.425589678238707778.davem@davemloft.net>
 <20161201224827.GA26301@amd>
 <2ceae6dc-3a48-3212-c634-cc6f1f0b363f@st.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="PNTmBPCT7hxwcZjr"
Cc: David Miller <davem@davemloft.net>, alexandre.torgue@st.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <2ceae6dc-3a48-3212-c634-cc6f1f0b363f@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--PNTmBPCT7hxwcZjr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> >Anyway... since you asked. I belive I have way to disable NAPI / tx
> >coalescing in the driver. Unfortunately, locking is missing on the rx
> >path, and needs to be extended to _irqsave variant on tx path.
>=20
> I have just replied to a previous thread about that...

Yeah, please reply to David's mail where he describes why it can't
work.

> >So patch currently looks like this (hand edited, can't be
> >applied, got it working few hours ago). Does it look acceptable?
> >
> >I'd prefer this to go after the patch that pulls common code to single
> >place, so that single place needs to be patched. Plus I guess I should
> >add ifdefs, so that more advanced NAPI / tx coalescing code can be
> >reactivated when it is fixed. Trivial fixes can go on top. Does that
> >sound like a plan?
>=20
> Hmm, what I find strange is that, just this code is running since a
> long time on several platforms and Chip versions. No raise condition
> have been found or lock protection problems (also proving look
> mechanisms).

Well, it works better for me when I disable CONFIG_SMP. It is normal
that locking problems are hard to reproduce :-(.

> Pavel, I ask you sorry if I missed some problems so, if you can
> (as D. Miller asked) to send us a cover letter + all patches
> I will try to reply soon. I can do also some tests if you ask
> me that! I could run on 3.x and 4.x but I cannot promise you
> benchmarks.

Actually... I have questions here. David normally pulls from you (can
I have a address of your git tree?).

Could you apply these to your git?

[PATCH] stmmac ethernet: unify locking
[PATCH] stmmac: simplify flag assignment
[PATCH] stmmac: cleanup documenation, make it match reality

They are rather trivial and independend, I'm not sure what cover
letter would say, besides "simple fixes".

Then I can re-do the reset on top of that...

> >Which tree do you want patches against?
> >
> >https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/ ?
>=20
> I think that bug fixing should be on top of net.git but I let Miller
> to decide.

Hmm. It is "only" a performance problem (40msec delays).. I guess
-next is better target.

Best regards,
								Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--PNTmBPCT7hxwcZjr
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlhBUB4ACgkQMOfwapXb+vIyUACdG+ClPNPRNSYutf9Mh5cJLl8A
EwoAniX6EFkyByRMkJmLHyW4uJo/uc5q
=WhY6
-----END PGP SIGNATURE-----

--PNTmBPCT7hxwcZjr--
