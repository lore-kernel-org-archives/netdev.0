From: Corinna Vinschen <vinschen@redhat.com>
Subject: Re: [PATCH net 1/1] r8169: fix sleepable allocation during netdevice
 stats retrieval.
Date: Thu, 10 Sep 2015 10:47:09 +0200
Message-ID: <20150910084709.GB19486@calimero.vinschen.de>
References: <20150907085023.GA17511@calimero.vinschen.de>
 <55EDA281.3030706@gmail.com>
 <55EE81D8.4010008@gmail.com>
 <55F04F40.4040901@gmail.com>
 <20150909155404.GC19913@calimero.vinschen.de>
 <20150909155511.GD19913@calimero.vinschen.de>
 <55F07BBC.9020308@gmail.com>
 <20150909190805.GA26699@calimero.vinschen.de>
 <55F0BCB6.5030508@gmail.com>
 <55F0C5F5.4040101@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="Fba/0zbH8Xs+Fj9o"
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Mike Massonnet <m8t@gandi.net>,
	Bernhard Walle <bernhard.walle@gmx.de>,
	Hendrik Scholz <hscholz@raisdorf.net>,
	Florian Rivoal <frivoal@xfce.org>
To: poma <pomidorabelisima@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-n.franken.de ([193.175.24.27]:36808 "EHLO
	mail-n.franken.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753143AbbIJIrM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2015 04:47:12 -0400
Content-Disposition: inline
In-Reply-To: <55F0C5F5.4040101@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Fba/0zbH8Xs+Fj9o
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sep 10 01:51, poma wrote:
> [PATCH v2] r8169: Fix sleeping function called during get_stats64
> http://www.spinics.net/lists/netdev/msg342490.html
> - the noise is still present
>=20
> Corinna, care to share kernel-core & kernel-modules you are testing with,
> to unravel the Gordian Knot?

Somehow your initrd seem to refuse to pick up the new kernel module.

Here's basically what I do:

- Test system is RHEL7

- git clone git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git

- edit drivers/net/ethernet/realtek/r8169.c

- make config; make -j42

- make install_modules && make install

- init 6

Alternatively, if you already did the above once:

- git am <from http://www.spinics.net/lists/netdev/msg342490.html>

- make modules

- cp drivers/net/ethernet/realtek/r8169.ko \
  /lib/modules/4.2.0+/kernel/drivers/net/ethernet/realtek/r8169.c

- dracut -f --kver '4.2.0+'

- init 6


Corinna

--Fba/0zbH8Xs+Fj9o
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJV8UONAAoJEPU2Bp2uRE+gzIEP/i+QnlQHFxSNG8YhhEnb0hZs
AuW4RZUFjnRtcEFrjS8cVClQx+iwy8PZlLApS4pidumc6NLg3MRLZFWg0AXoWEfl
8FbHY7XguF8Imi6bVco8RCD3eFulJgg9MQvszDvE5zh/icZiOypNvAtOiujH4eFZ
TRgawuNkZIAVGJjKkSLUnfWNda/bsaVP6nYzI47VhnrcRKl7zsKEp5CL+uV/sVRL
NqgaWlVQn+hXFI2EcZe7Hgmwtcj0uUaCsIv/R0Oqt4AcYOdMm9FhYCI6YELBxy0M
UIqgwYOHwo58yopNeNHZILKauDQB0D46L5vV8Z83GLZahXag9EYzyyjn2lW9fc4Q
ziQUUGUum8xokQeK9F85iT04zI7z0LfX/ogX0KpV0Klm16ZPZGv/iEinWCOkJMOc
weY4su+tKzRA/xEUugJght5HU88/3s9fCq9S5uNfXhhZ3HpcdYjLiGz2+N8ux5dU
y6hBP7LPGzoMD2EJMs+9H5LtHMcqYaV5J0+pol00vseiA15fP2AHkO4MY8tuTmwR
XoUFr/KVstLdin2N/USoFwtq3hy3T2EnhH85X+48Hg2odXIZGMDmw9l9IU/USxKT
1+0VG/5dTmCodL0LciBpCsu+P/Phl1ku50c60e7lBYGhGzO/TXy3Nzmp4ixnzKUE
hXtSBnOL8WXzIQVVXeK2
=2TIA
-----END PGP SIGNATURE-----

--Fba/0zbH8Xs+Fj9o--
