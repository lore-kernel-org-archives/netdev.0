From: Marek =?utf-8?Q?Marczykowski-G=C3=B3recki?=
	<marmarek@invisiblethingslab.com>
Subject: Re: [Xen-devel] xen-netfront crash when detaching network while some
 network activity
Date: Fri, 22 May 2015 19:13:35 +0200
Message-ID: <20150522171335.GG957@mail-itl>
References: <20150522114932.GC8664@mail-itl>
 <555F5888.4020303@citrix.com>
 <20150522164246.GE957@mail-itl>
 <555F6041.7000203@citrix.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="xSu31lw3TgkWXnjh"
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	netdev@vger.kernel.org, xen-devel <xen-devel@lists.xen.org>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:35156 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964813AbbEVRNm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 13:13:42 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id D8B7120833
	for <netdev@vger.kernel.org>; Fri, 22 May 2015 13:13:41 -0400 (EDT)
Content-Disposition: inline
In-Reply-To: <555F6041.7000203@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--xSu31lw3TgkWXnjh
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, May 22, 2015 at 05:58:41PM +0100, David Vrabel wrote:
> On 22/05/15 17:42, Marek Marczykowski-G=C3=B3recki wrote:
> > On Fri, May 22, 2015 at 05:25:44PM +0100, David Vrabel wrote:
> >> On 22/05/15 12:49, Marek Marczykowski-G=C3=B3recki wrote:
> >>> Hi all,
> >>>
> >>> I'm experiencing xen-netfront crash when doing xl network-detach while
> >>> some network activity is going on at the same time. It happens only w=
hen
> >>> domU has more than one vcpu. Not sure if this matters, but the backend
> >>> is in another domU (not dom0). I'm using Xen 4.2.2. It happens on ker=
nel
> >>> 3.9.4 and 4.1-rc1 as well.
> >>>
> >>> Steps to reproduce:
> >>> 1. Start the domU with some network interface
> >>> 2. Call there 'ping -f some-IP'
> >>> 3. Call 'xl network-detach NAME 0'
> >>
> >> I tried this about 10 times without a crash.  How reproducible is it?
> >>
> >> I used a 4.1-rc4 frontend and a 4.0 backend.
> >=20
> > It happens every time for me... Do you have at least two vcpus in that
> > domU? With one vcpu it doesn't crash. The IP for ping I've used one in
> > backend domU, but it shouldn't matter.
> >=20
> > Backend is 3.19.6 here. I don't see any changes there between rc1 and
> > rc4, so stayed with rc1. With 4.1-rc1 backend it also crashes for me.
>=20
> Doesn't repro for me with 4 VCPU PV or PVHVM guests.

I've tried with exactly 2 vcpus in frontend domU (PV), but I guess it
shouldn't matter. Backend is also PV.

> Is your guest
> kernel vanilla or does it have some qubes specific patches on top?

This one was from vanilla - both frontend and backend (just qubes
config).
Maybe something about device configuration? Here is xenstore dump:
frontend:
0 =3D ""
 backend =3D "/local/domain/66/backend/vif/69/0"
 backend-id =3D "66"
 state =3D "4"
 handle =3D "0"
 mac =3D "00:16:3e:5e:6c:07"
 multi-queue-num-queues =3D "2"
 queue-0 =3D ""
  tx-ring-ref =3D "1280"
  rx-ring-ref =3D "1281"
  event-channel-tx =3D "19"
  event-channel-rx =3D "20"
 queue-1 =3D ""
  tx-ring-ref =3D "1282"
  rx-ring-ref =3D "1283"
  event-channel-tx =3D "21"
  event-channel-rx =3D "22"
 request-rx-copy =3D "1"
 feature-rx-notify =3D "1"
 feature-sg =3D "1"
 feature-gso-tcpv4 =3D "1"
 feature-gso-tcpv6 =3D "1"
 feature-ipv6-csum-offload =3D "1"

backend:
69 =3D ""
 0 =3D ""
  frontend =3D "/local/domain/69/device/vif/0"
  frontend-id =3D "69"
  online =3D "1"
  state =3D "4"
  script =3D "/etc/xen/scripts/vif-route-qubes"
  mac =3D "00:16:3e:5e:6c:07"
  ip =3D "10.137.3.9"
  handle =3D "0"
  type =3D "vif"
  feature-sg =3D "1"
  feature-gso-tcpv4 =3D "1"
  feature-gso-tcpv6 =3D "1"
  feature-ipv6-csum-offload =3D "1"
  feature-rx-copy =3D "1"
  feature-rx-flip =3D "0"
  feature-split-event-channels =3D "1"
  multi-queue-max-queues =3D "2"
  hotplug-status =3D "connected"


--=20
Best Regards,
Marek Marczykowski-G=C3=B3recki
Invisible Things Lab
A: Because it messes up the order in which people normally read text.
Q: Why is top-posting such a bad thing?

--xSu31lw3TgkWXnjh
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJVX2O/AAoJENuP0xzK19csMcsH/3QRDAZvxlRTysCLBADkIfNv
iz+nk5Kj4IaNPd9aAT7DeLJrPiO3701NFae84wJ2fYpBwfCgwguca1zw0WT178ow
LX/1474PyLMvoDbcx9vqqu0cWgz7/kvsdtQQDq747Bis0gmxg3/IRQ2zX12BkUZ6
tQ/M3jOzhNk4KRPfeR0InWSuV8Qtijmf9khBJY8bYNScsQJp3XvArYZtdeMFMfdg
gRSxISQpY2gIzr5QYAylnea9Dw+GW6fRuih9fN/oJTEJ6RjB01JvqunT1gF8j0ro
4Fy0J9j4PcSccMZfkm4G9l6AHxOvw9XTrryU3Nml8HAC+sPm5U6R1pQtIOuRV0k=
=3Y2e
-----END PGP SIGNATURE-----

--xSu31lw3TgkWXnjh--
