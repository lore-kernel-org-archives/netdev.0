From: David Meyer <dmm@1-4-5.net>
Subject: "right" way to requeue a packet to IP from ip_rcv?
Date: Mon, 23 Nov 2009 11:40:09 -0800
Message-ID: <20091123194009.GA24473@1-4-5.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="d6Gm4EdcadzBjdND"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m106.maoz.com ([205.167.76.9]:45189 "EHLO m106.maoz.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753758AbZKWTpJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2009 14:45:09 -0500
Received: from m106.maoz.com (localhost [127.0.0.1])
	by m106.maoz.com (8.14.3/8.14.3/Debian-6) with ESMTP id nANJeAX8024726
	for <netdev@vger.kernel.org>; Mon, 23 Nov 2009 11:40:10 -0800
Received: (from dmm@localhost)
	by m106.maoz.com (8.14.3/8.14.3/Submit) id nANJeAbT024725
	for netdev@vger.kernel.org; Mon, 23 Nov 2009 11:40:10 -0800
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--d6Gm4EdcadzBjdND
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


	Folks,

	I'm receiving an encapsulated packet that looks like

		outer   iph
		outer   udph
		foreign header
		inner   iph
		inner   udph
		data


	What I'd like to do is strip off the outer IP, UDP and
	foreign headers in ip_rcv and requeue the packet to IP to
	process the rest of the packet (inner IP header,
	etc). What's the clean way to do this?  In freeBSD you
	might do something like

	(*inetsw[ip_protox[ip->ip_p]].pr_input)(m, hlen);

	but I'm not exactly sure what the analogous thing is for
	linux. Any insight greatly appreciated.

	Thnx,

	Dave


=09

--d6Gm4EdcadzBjdND
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAksK5RkACgkQORgD1qCZ2Kd+XgCcDBlfwTRQwufrCSKP02BS1kLy
dqcAn2MS2J30RBe0jsPqH+bEouaE6BCP
=f3xa
-----END PGP SIGNATURE-----

--d6Gm4EdcadzBjdND--
