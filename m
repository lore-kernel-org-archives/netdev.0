From: Sven Eckelmann <sven.eckelmann-Mmb7MZpHnFY@public.gmane.org>
Subject: Re: [PATCHv4] net: Add batman-adv meshing protocol
Date: Wed, 8 Sep 2010 20:58:14 +0200
Message-ID: <201009082058.15533.sven.eckelmann@gmx.de>
References: <1283646353-17811-1-git-send-email-sven.eckelmann@gmx.de>
	<201009081142.31610.sven.eckelmann@gmx.de>
	<AANLkTimnBqkiO26wqEQOm+AgSJgQLtQmAe8R-kB6CqtZ@mail.gmail.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart6760549.a6m0x8x2ty";
	protocol="application/pgp-signature"; micalg=pgp-sha512
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	b.a.t.m.a.n-ZwoEplunGu2X36UT3dwlltHuzzzSOjJt@public.gmane.org
To: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <AANLkTimnBqkiO26wqEQOm+AgSJgQLtQmAe8R-kB6CqtZ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

--nextPart6760549.a6m0x8x2ty
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Jesse Gross wrote:
> On Wed, Sep 8, 2010 at 2:42 AM, Sven Eckelmann <sven.eckelmann-Mmb7MZpHnFY@public.gmane.org>=20
wrote:
> > Hi,
> >=20
> > here are some raw references without any judgment. Maybe Marek will send
> > some more information about that topic later.
> >=20
> > Andi Kleen wrote:
> >> Sven Eckelmann <sven.eckelmann-Mmb7MZpHnFY@public.gmane.org> writes:
> >> > B.A.T.M.A.N. (better approach to mobile ad-hoc networking) is a
> >> > routing protocol for multi-hop ad-hoc mesh networks. The networks may
> >> > be wired or wireless. See http://www.open-mesh.org/ for more
> >> > information and user space tools.
> >>=20
> >> It seems rather unusual to have the complete routing protocol in
> >> kernel. And this is a lot of code. The normal way to do such things is
> >> to have the routing policy etc. in a user daemon and only let the kern=
el
> >> provide some services to this.
> >>=20
> >> Could you elaborate a bit why this approach was not chosen?
> >>=20
> >> I assume if it needs a switch it could have a switching "hot path" lay=
er
> >> in kernel and the policy somewhere else.
>=20
> Potentially one way to do this is to build on top of Open vSwitch.  It
> contains a pretty generic flow-based kernel module for forwarding data
> packets and making simple modifications.  Control packets can be sent
> to userspace to handle the routing logic, while data packets remain in
> the kernel for performance.  This would dramatically reduce the amount
> of code that needs to be in the kernel and may even help performance
> by simplifying the fast path.
>=20
> I don't know the details of your protocol well enough to know if this
> is feasible but it seems like something you might want to look into.
> Open vSwitch is currently in the process of finalizing its interfaces
> to prepare for upstreaming.

It sounds interesting. I haven't looked into it yet, but maybe you could=20
easily answer some questions:
 * Does it allow to generate multiple net_devices on the system?
 * Does it allow to attach multiple net_devices to a single openvswitch
   device?
 * Does the attaching of a net_device to a openvswitch device prevent it to=
 be
   added to another openvswitch device?
 * Does it propagate the information about the incoming device to the
   userspace in case of the not routed packets (everything which should
 * Does it allow to append extra header information to the packet?
 * Does it allow fragmentation of packets (not real fragmentation, but more
   single split)?
 * Does it allow to define outgoing patterns (on which attached interface
   goes the thing out again) on packet number or incoming device (the real
   hardware device it was coming in)?
 * Is it possible to define rules like: "If this is a broadcast of an udp/ip
   packet with target port 123 which may or may not have a vlan tag, but is
   coming directly from the virtual device and is not routed by us, then
   change the mac address to following"?
 * Can it be backported to old kernels (~2.6.21 - yes, their are "customers=
"=20
   who need even older kernels due to the fantastic vendors out their)?

Thanks,
	Sven

--nextPart6760549.a6m0x8x2ty
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIcBAABCgAGBQJMh9zGAAoJEF2HCgfBJntG2DUQAIWWaGTq9VE2HOyupUD3Ulye
BYQ/6/ycX1EGJoWmeBRMZn0YqQl5WG0pnlraIkOWVNTCjSwgifFB5D3G1YaGFI0J
Hsw6M6Y7+CMnCJo7xXugkoN68dyIQhetMtz1guUlrtJI4IIIKI5FgkILqmUo5kbE
5gwLkaVxoYRutxsUdP0e58e6UCGDSYRQ9FEffwjK//QP3mSm/LtI3xoOB/1BaZTs
ffHwVHHqoOD2hWYFfIMhUJHjomM0pWM96WJmIy/nbLFUSfEvBfcPGaTNwIJ/kV8y
qmRfgnKyTolNEEnayqjORLeFdJhzvLGBgJxGmsEaB1VOrD6WNLyINj9EFjXnNJLc
mBvPM02BhiEZLeprl/9q6aDr9rjz90cCpYLU4oLUfVB7C5t4wo1/27XRNVVXWUaS
LtRU3u2serYOCOZ25kavneHyIhd69nLEdsYUmARK+5Ae3YnuZTNV8+XFpNrWwm6f
dVMZV1kFbFlXoG/UBVWsm2agYo3h3QcMPotePsfquYSGbtWKw1w4PB3qo85M2Mxa
jxuLpLTocjF5Mx6RcreGyRHE7Fjr1JXYyyWbpNphWca2GXtDZyQa0z8i9F5nIca+
gHkwU1Lv2ubemjY1vavmqo4NAtLKo1AsabTmykjpa3dw3BXCyl/qAi6sgoe0sfLV
947tBbfmCCF3SMvpMKQv
=8jTQ
-----END PGP SIGNATURE-----

--nextPart6760549.a6m0x8x2ty--
