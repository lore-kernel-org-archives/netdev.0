From: md@Linux.IT (Marco d'Itri)
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Sun, 11 Oct 2009 02:37:48 +0200
Message-ID: <20091011003748.GA28600@bongo.bofh.it>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com> <20091009140000.GA18765@mock.linuxdev.us.dell.com> <20091009210909.GA9836@auslistsprd01.us.dell.com> <20091009194401.036da080@nehalam> <20091010044056.GA5350@mock.linuxdev.us.dell.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="huq684BweRXVnRxX"
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	linux-hotplug@vger.kernel.org, Narendra_K@dell.com,
	jordan_hargrave@dell.com
To: Matt Domsch <Matt_Domsch@dell.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091010044056.GA5350@mock.linuxdev.us.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--huq684BweRXVnRxX
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Oct 10, Matt Domsch <Matt_Domsch@dell.com> wrote:

> It does require a change in behavior for a system administrator.
> Instead of hard-coding 'eth0' into her scripts, she uses
> '/dev/net/by-function/boot' or somesuch.  But then that name is
> guaranteed to always refer to the "right" NIC.  Every admin I've
> spoken to is willing to make this kind of change, as long as they get
> the consistent, deterministic naming they expect but don't have
> today.  And it does require patching userspace apps to take both a
> kernel device name, or a path, and to resolve the path to device name
> or ifindex.  We wrote libnetdevname (really, one function), and have
> patches for several userspace apps to use it, to prove it can be done.
For the records, before being a distribution developer I am a system
administrator (who designed and manages many firewalls with multiple
network interfaces) and I am still unconvinced that what you are
proposing is a practical solution and that its downsides justify the
significant changes both in software and in system administration
practices that it requires.
The first issue which greatly concerns me is the need to modify *every*
userspace application and kernel tool (what about iptables? What about
the kernel logs?): from an users experience point of view it would be
very annoying if different applications used different names to refer to
the same network device.
I am also concerned with the practical implications of trying to use
such long (and unusual) names: IFNAMSIZ is 16, so user interfaces tend
to assume both short names and that they match something like
/^[a-z0-9]+$/. What about e.g. distribution scripts which use the
interface name as a file system path component? Do you already have a
(standard) scheme to losslessly convert the names to a form without
slashes?

--=20
ciao,
Marco

--huq684BweRXVnRxX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkrRKNwACgkQFGfw2OHuP7GWqQCgkZZ5c+Cju8OozrMLWXSadP6l
SSQAn36cad+szuQLjv952ECJ+NIhDO/h
=KaFM
-----END PGP SIGNATURE-----

--huq684BweRXVnRxX--
