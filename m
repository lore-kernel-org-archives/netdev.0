From: Mike Kershaw <dragorn@kismetwireless.net>
Subject: Re: sysfs vs. d80211 configuration
Date: Mon, 14 Aug 2006 20:07:06 -0400
Message-ID: <20060815000706.GE5672@drd1812a>
References: <44E07662.8070506@sipsolutions.net> <Pine.NEB.4.64.0608142302560.21364@otaku.freeshell.org>
Reply-To: Mike Kershaw <dragorn@kismetwireless.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="84ND8YJRMFlzkrP4"
Cc: Johannes Berg <johannes@sipsolutions.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from melchior.nerv-un.net ([216.179.125.34]:49416 "EHLO nerv-un.net")
	by vger.kernel.org with ESMTP id S965079AbWHOAHx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 20:07:53 -0400
To: Alexey Toptygin <alexeyt@freeshell.org>
Content-Disposition: inline
In-Reply-To: <Pine.NEB.4.64.0608142302560.21364@otaku.freeshell.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--84ND8YJRMFlzkrP4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Aug 14, 2006 at 11:05:15PM +0000, Alexey Toptygin wrote:
> On Mon, 14 Aug 2006, Johannes Berg wrote:
>=20
> >In my seemingly never-ending quest to actually use the d80211 stack for=
=20
> >something useful I just wanted to write a small setuid tool that:
> >* creates and opens a new monitor interface
> >* drops priviledges
> >* ... does things with received frames ... (not interesting for this=20
> >discussion)
> >* removes new monitor interface
> >
> >So I figured I'd just keep an fd open to=20
> >/sys/class/net/mymonitorinterface/remove_iface to which I could write th=
e=20
> >interfaces name after I was done with it. However, when writing to that =
fd=20
> >I got -EACCESS because it checks for CAP_NET_ADMIN.
>=20
> Why not have the tool create a monitor interface, open it, and fork; the=
=20
> child drops privileges and does the reading, and the parent wait(2)s for=
=20
> the child and removes the interface once it has collected the child?

Kismet achieves this nearly the same way -- It keeps a root process for
channel control, and talks over IPC to a nonpriv process.  When it's
done, it sends the shutdown command to the root process and restores the
interface settings (or removes monitor interfaces, etc). =20

If you set up all your interfaces before the fork you can keep the IPC
very simple.

-m

--=20
Mike Kershaw/Dragorn <dragorn@kismetwireless.net>
GPG Fingerprint: 3546 89DF 3C9D ED80 3381  A661 D7B2 8822 738B BDB1

--84ND8YJRMFlzkrP4
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQFE4RAq17KIInOLvbERAo+XAKDUxhf8FKgTEPzZ3dCbE4gV5pAJSQCeIwLI
tNZ0nsYMoCK0oj2498oXGCk=
=b+nD
-----END PGP SIGNATURE-----

--84ND8YJRMFlzkrP4--
