From: Nikola Ciprich <nikola.ciprich@linuxbox.cz>
Subject: bnx2x - occasional high packet loss (on LAN)
Date: Tue, 15 Sep 2015 06:17:26 +0200
Message-ID: <20150915041726.GD6850@pcnci.linuxbox.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="IMjqdzrDRly81ofr"
Cc: nik@linuxbox.cz
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gwu.lbox.cz ([62.245.111.132]:45433 "EHLO gwu.lbox.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751389AbbIOEfV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Sep 2015 00:35:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--IMjqdzrDRly81ofr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello,

I'm trying to track strange issue with one of our servers and
like to ask for recommendations..

I've got three node cluster (nodes A..C) interconnected with stacked broadc=
om
ICX6610. eth0 of each box is connected to first switch, eth1 to second one,
bonding set as follows: "mode=3D802.3ad lacp_rate=3Dfast xmit_hash_policy=
=3Dlayer2+3 miimon=3D100"

It happened few times, that suddenly eth1 on box A started misbehaving and =
communication
with other nodes (ie flood ping) started dropping up to 30% packets. When t=
his port
has been shut on both sides, problem immediately vanished.

We've tried replacing card, cable and using different port on switch, but p=
roblem
repeated again yesterday..

Since it's "only" loss, and not link loss, bonding doesn't help me much..

however during weekend, port also had strange link issue:

Sep 12 15:23:45 remrprv1a kernel: [676373.296786] bnx2x 0000:03:00.1 eth1: =
NIC Link is Down
Sep 12 15:23:46 remrprv1a kernel: [676373.356638] bond0: link status defini=
tely down for interface eth1, disabling it
Sep 12 15:23:46 remrprv1a kernel: [676374.299571] bnx2x 0000:03:00.1 eth1: =
NIC Link is Up, 10000 Mbps full duplex, Flow control: ON - receive & transm=
it
Sep 12 15:23:47 remrprv1a kernel: [676374.364428] bond0: link status defini=
tely up for interface eth1, 10000 Mbps full duplex
Sep 12 15:23:47 remrprv1a kernel: [676374.372902] bond0: first active inter=
face up!
Sep 12 15:24:24 remrprv1a kernel: [676411.402511] bnx2x 0000:03:00.1 eth1: =
NIC Link is Down
Sep 12 15:24:24 remrprv1a kernel: [676411.407422] bond0: link status defini=
tely down for interface eth1, disabling it
Sep 12 15:24:25 remrprv1a kernel: [676412.405311] bnx2x 0000:03:00.1 eth1: =
NIC Link is Up, 10000 Mbps full duplex, Flow control: ON - receive & transm=
it
Sep 12 15:24:25 remrprv1a kernel: [676412.408123] bond0: link status defini=
tely up for interface eth1, 0 Mbps full duplex
Sep 12 15:24:51 remrprv1a kernel: [676438.477641] bnx2x 0000:03:00.1 eth1: =
NIC Link is Down
Sep 12 15:24:51 remrprv1a kernel: [676438.528513] bond0: link status defini=
tely down for interface eth1, disabling it
Sep 12 15:24:52 remrprv1a kernel: [676439.480472] bnx2x 0000:03:00.1 eth1: =
NIC Link is Up, 10000 Mbps full duplex, Flow control: ON - receive & transm=
it
Sep 12 15:24:52 remrprv1a kernel: [676439.536282] bond0: link status defini=
tely up for interface eth1, 10000 Mbps full duplex

0mbps link speed is quite weird I guess..

all three boxes are the same, running centos6 based system, 4.0.5 x86_64 ke=
rnel.

The only difference I noticed on them is, that irqbalance was enabled on pr=
oblematic
box and not on the others.. So I disabled it and rebooted the box.. The pro=
blem is,
I can't really wait for the problem to reappear, so I'd like to ask, has an=
ybody
seen similar problem? I of so, was it fixed in some newer kernel release? I=
 haven't
found mention in the changelogs, but still.. or does somebody have a hint o=
n what else
I should check?=20

I'll try to reproduce this on test system (enabling irqbalance and doing so=
me network
benchmarks, but I'd be most happy if I could prevent it on this production =
system..)

thanks a lot for any advance

with best regards

nikola ciprich

PS: here's lspci -vv of eths.. should I provide any further information, pl=
ease let me know:

http://nik.lbox.cz/download/lspci.txt

--=20
-------------------------------------
Ing. Nikola CIPRICH
LinuxBox.cz, s.r.o.
28.rijna 168, 709 00 Ostrava

tel.:   +420 591 166 214
fax:    +420 596 621 273
mobil:  +420 777 093 799
www.linuxbox.cz

mobil servis: +420 737 238 656
email servis: servis@linuxbox.cz
-------------------------------------

--IMjqdzrDRly81ofr
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEARECAAYFAlX3m9YACgkQ3xdJJrLygV7cHgCfal5ul2RHrZ6YaeYRd0gKJhwR
95oAoNGP+MJr1QXR5x54O1YDrg+mlFdN
=9E2N
-----END PGP SIGNATURE-----

--IMjqdzrDRly81ofr--
