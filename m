From: Athanasius <link@miggy.org>
Subject: Re: [Bugme-new] [Bug 8961] New: BUG triggered by oidentd in netlink code
Date: Sat, 1 Sep 2007 18:39:44 +0100
Message-ID: <20070901173944.GB3693@miggy.org>
References: <bug-8961-10286@http.bugzilla.kernel.org/> <20070830180842.7c8414fe.akpm@linux-foundation.org> <Pine.LNX.4.64.0708311258520.8423@x2> <20070831123825.GW22067@miggy.org> <46D9957F.4020101@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="qMm9M+Fa2AknHoGS"
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Patrick McHardy <kaber@trash.net>,
	linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fysh.org ([83.170.75.51]:38752 "EHLO bowl.fysh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754091AbXIARjs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Sep 2007 13:39:48 -0400
Content-Disposition: inline
In-Reply-To: <46D9957F.4020101@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--qMm9M+Fa2AknHoGS
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Sep 01, 2007 at 06:38:23PM +0200, Patrick McHardy wrote:
> Athanasius wrote:
> >  I'll compile up a new kernel, likely 2.6.22.6, plus this patch, and
> >reboot to it tonight.  I still don't know *exactly* how to trigger the
> >bug on demand though, it's not reocurred since I posted the bug report
> >(but had happened about a week before as well).
>=20
> Thanks. I'm not sure either, it would require two concurrent requests
> to be processed, but AFAICS oidentd only uses a single netlink socket.
> Perhaps multiple running instances or something else using the inet_diag
> interface?
>=20
> You might be able to trigger it without this patch by running
> "while true; do ss -tn; done" while doing ident queries, but
> just running the while loop a couple of times in parallel
> doesn't seem to trigger it here.

  I went for setting up a dummy listener in inetd, using tcpd, and
setting hosts.allow to specify myuser@ip.  Then a few while loops
spamming it with connections using nc.

  Anyway, on the old kernel that managed to trigger the BUG twice in
about 30 minutes.  I'm now on 2.6.22.6 plus your patch and coming up on
an hour (55+ mins) of the same and no sign of the BUG.

  So that looks like fixed to me.  I'll weigh in again if the daily
logcheck throws up another.

-Ath
--=20
- Athanasius =3D Athanasius(at)miggy.org / http://www.miggy.org/
                  Finger athan(at)fysh.org for PGP key
	   "And it's me who is my enemy. Me who beats me up.
Me who makes the monsters. Me who strips my confidence." Paula Cole - ME

--qMm9M+Fa2AknHoGS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFG2aPgIr2uvLNOS8MRAuH9AJ4pHA+ymQNSEvstqK3BG/IDta0LvgCfe58A
fgipEqGE1kuf9zpQq0qkBz8=
=7ln7
-----END PGP SIGNATURE-----

--qMm9M+Fa2AknHoGS--
