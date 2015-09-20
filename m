From: Matthew Monaco <Matthew.Monaco@Colorado.EDU>
Subject: Re: sr-iov and bridges (mlx4)
Date: Sun, 20 Sep 2015 12:45:14 -0600
Message-ID: <55FEFEBA.6020903@colorado.edu>
References: <55FDF69F.6000105@colorado.edu>
 <CAJ3xEMg1HR+WfhUNMCu9mnXp6F9Vuw8=VkrUvcynAn3VWoP2Gw@mail.gmail.com>
 <55FEDCFE.30506@colorado.edu> <8f15ec904f631f2d792388128b34732a@justnet.pl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="LX5BqPfgG6j8b4tidIt5aC5jpvaoGBg9s"
Cc: adam.niescierowicz@justnet.pl
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:38580 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755096AbbITSpV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Sep 2015 14:45:21 -0400
Received: by igxx6 with SMTP id x6so45913439igx.1
        for <netdev@vger.kernel.org>; Sun, 20 Sep 2015 11:45:20 -0700 (PDT)
In-Reply-To: <8f15ec904f631f2d792388128b34732a@justnet.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--LX5BqPfgG6j8b4tidIt5aC5jpvaoGBg9s
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 09/20/2015 12:18 PM, Nie=C5=9Bcierowicz Adam wrote:
> Hi Matthew,
> in near future i want to do exactly the same, if you make progress with=

> SR-IOV+Bridge+OpenStack please leave here some advice.
>=20

I wrote a shell script which polls (~15s) each bridge /sys/class/net/brq*=
, and
for each bridge figures out the uplink (not named
/sys/class/net/brq*/brif/tap*). Then, for each port
/sys/class/net/<bridge>/brif/tap*, determine the VM mac address and add a=
n fdb
entry if it doesn't already exist. In my environment, it seems the VM mac=
 is the
tap mac s/^fe:/fa:/.

This is a little messier than the non-promsicuous bridge option, but I wa=
sn't
able to get that working on CentOS7/kernel-ml-4.2/iproute-3.10. But eithe=
r way,
this won't work well if you're trying to do nested virt, which thankfully=
 I
don't need at this time.

If you're interested I can attach the script and systemd unit. Otherwise,=
 I'll
be looking to try to get this handled properly by neutron-linuxbridge-age=
nt.


--LX5BqPfgG6j8b4tidIt5aC5jpvaoGBg9s
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCgAGBQJV/v66AAoJEAi+uryZEuPoM8IH/07smFWZLacT/5++gUD9bSlO
Qxxghx9e1sFktNs/AKjwSpNvG9lS63hoBD/HUN2seqfnfe5eN/lyl7vk6jkcpTcY
dWYxxxcdlY0brK5fian3ayTy/VBQyTeZHPbADU5cAV4ivOS8Qf6k2teOmNNCwaLk
96nwB251XFYii+qetG9YNSdgoi4ymcEFFX2K7s0k5a7ZADMeXonjsZWStDFSYO2z
4elXhWR2ueWyIqoSJO0LRhordiQf/eBbU3KEhcgMeUpZLwgJ6AvJPL7bjSV6aPsE
JdnNaIQRfLjVrbCAB6OBFcdxX+CWZclJyShygoUkFq6jJs7lAOVa/cA+HzN4rcs=
=LHpp
-----END PGP SIGNATURE-----

--LX5BqPfgG6j8b4tidIt5aC5jpvaoGBg9s--
