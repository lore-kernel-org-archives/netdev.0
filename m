From: Simon Wunderlich <simon.wunderlich-Y4E02TeZ33kaBlGTGt4zH4SGEyLTKazZ@public.gmane.org>
Subject: Re: [PATCHv4] net: Add batman-adv meshing protocol
Date: Tue, 14 Sep 2010 21:21:02 +0200
Message-ID: <20100914192102.GA30906@pandem0nium>
References: <1283646353-17811-1-git-send-email-sven.eckelmann@gmx.de>
	<201009082058.15533.sven.eckelmann@gmx.de>
	<AANLkTi=FVyLE6OHTd+_qDbzSLk6fY5j6wBOWkYA810Dj@mail.gmail.com>
	<201009082225.47498.sven.eckelmann@gmx.de>
	<AANLkTim-jswWzG=H0AQP5Z3byxoR1uXoV-ZhdaZ7+Sqd@mail.gmail.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="k1lZvvs/B4yU6o8G"
To: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org, Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, Sven Eckelmann <sven.eckelmann-Mmb7MZpHnFY@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AANLkTim-jswWzG=H0AQP5Z3byxoR1uXoV-ZhdaZ7+Sqd-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org


--k1lZvvs/B4yU6o8G
Content-Type: text/plain; charset=utf8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello,

thank you for your comments. As already said, splitting batman-advanced into
a kernel space part for switching and a user space part for making route
decision is an already discussed idea which is quite interesting. I wouldn't
say that it's completely unusual to decide routing in the kernel, as we see
other mesh protocols like 802.11s/HWMP or STP (not really a mesh protocol)
integrated in the kernel as well. We have discussed a possible openvswitch =
port
internally with some of the main contributors, and we see the following iss=
ues:

Looking at openvswitch, it seems that the target application is very differ=
ent.
batman-adv is targeted to support 802.11 WiFi networks on low-end hardware,=
 while
openvswitch was designed as switching environment for virtual machines. This
implies different design decisions - batman-adv should be able to run witho=
ut any
additional userspace applications if needed, while openvswitch comes with q=
uite a
big, rich featured environment required for operation.

Next to this fact, one thing which worries us is that openvswitch seems to
replace quite some standard linux tools/facilities (e.g. the bridge module),
which is often used in most of the APs we have seen, along with ebtables and
the configuration interfaces it provides. Changing to openvswitch would imp=
ly
to change the configuration interfaces and firmwares plus educating all our
users which depend on those standard tools.

Porting batman-adv to the openvswitch framework would of course require an
enormous effort itself. batman-adv as a software which is already "finished=
",
well tested and integrated in various products/firmwares and ready for kern=
el
integration. Porting to openvswitch would mean a step backwards for our pro=
ject
as it is not predictable for us when openvswitch will be finished or integr=
ated in
the kernel.

Maybe we should move forward in this direction after openvswitch is settled=
 as
the way to go for layer 2 tunneling/abstraction in the Linux kernel, but
currently we don't see the benefit for us to port it.

best regards,
    Simon   =20

--k1lZvvs/B4yU6o8G
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkyPyx4ACgkQrzg/fFk7axaG4QCfWW2n31p1Jtr02UtvfQ5D/Pof
Z1YAoLlkMQ1vXI7gjYISjoFMkHg///Nj
=Q48j
-----END PGP SIGNATURE-----

--k1lZvvs/B4yU6o8G--
