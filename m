From: Tomasz Paszkowski <tomasz.paszkowski@e-wro.pl>
Subject: Re: Fw: hfsc and huge set of rules
Date: Fri, 30 Jul 2004 13:08:15 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040730110815.GA7812@krezus.e-wro.net>
References: <20040729211844.61e8d328.davem@redhat.com> <410A2449.3020701@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="LZvS9be/3tNcYl/X"
Cc: "David S. Miller" <davem@redhat.com>, hadi@cyberus.ca, devik@cdi.cz,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <410A2449.3020701@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--LZvS9be/3tNcYl/X
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jul 30, 2004 at 12:34:49PM +0200, Patrick McHardy wrote:
> David S. Miller wrote:
> >Looks like qdisc destruction has some expensive algorithms.
> >Any quick ideas about the root culprit at least in the hfsc
> >case?  He says htb does it too.
>=20
> hfsc_destroy_qdisc takes O(n) time wrt. the number of classes,
> but 5-6 seconds is still long. If all these classes contain inner
> qdiscs other than the default, I guess removing the classes from
> dev->qdisc_list in qdisc_destroy takes up most of the time, with
> n O(n) operations. The __qdisc_destroy rcu callback also calls
> reset before destroy, I don't know any qdisc where this is really
> neccessary. Without inner qdiscs, I need to see the script first to
> judge what's going wrong. Tomasz ?

http://www.e-wro.pl/~acid/tc.batch.gz. In my opinion it's not the case
of expensive algorithms, but the number of classes. With this rule set load=
ed
(tc -b tc.batch) command:

for i in 'e1.903 e0.930 e0.931 e0.932' ; do
	tc qdisc del dev ${i} root
done
completly freezes machine for about 5-6 seconds.

I was trying do modify the code od hfsc_qdisc_destroy scheduling another
task using schedule_task (), but i don't have enough knowledge to do deal
with proper locking of qdisc structures.

--=20
Tomasz Paszkowski

--LZvS9be/3tNcYl/X
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQFBCiwfcNXOL98XeysRAlSMAKCM7HYVMAYP6yDx2dSgaoM3eCIy8gCfRBbU
+SbQkyCFUo5sjFRZ50ZkVrY=
=+Wgu
-----END PGP SIGNATURE-----

--LZvS9be/3tNcYl/X--
