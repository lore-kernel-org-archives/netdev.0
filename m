From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [net-next 01/16] ixgbe: add check for netif_carrier_ok in
 ixgbe_xmit_frame
Date: Sat, 15 Mar 2014 00:19:14 +0000
Message-ID: <1394842754.15764.13.camel@deadeye.wl.decadent.org.uk>
References: <1394790446-31591-2-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20140314.145735.289100032884651109.davem@davemloft.net>
	 <87618083B2453E4A8714035B62D679924FF2B099@FMSMSX105.amr.corp.intel.com>
	 <20140314.175131.1233519777786848021.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-LJgsn8ZunbuBYNZdfF1J"
Cc: emil.s.tantilov@intel.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	asharma@fb.com, stable@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20140314.175131.1233519777786848021.davem@davemloft.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-LJgsn8ZunbuBYNZdfF1J
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-03-14 at 17:51 -0400, David Miller wrote:
> From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
> Date: Fri, 14 Mar 2014 20:19:38 +0000
>=20
> > That would work, but what if there are other callers of
> > ndo_start_xmit that don't have this check? Handling this in the
> > driver takes care of all instances.
>=20
> netif_carrier_off() is supposed to stop traffic from flowing to
> the device.
>=20
> The qdisc layer should be honoring this property, and my
> suspicion is that it is just netpoll operates in the unique
> environment that doesn't.

There is no check for netif_carrier_ok() in the qdisc transmit path.
Instead netif_carrier_off() eventually causes link_watch to call
dev_deactivate() which installs the noop qdisc.

It does seem like transmitters that bypass the qdisc should be checking
netif_carrier_ok(), but drivers must also accept that the effect of
netif_carrier_off() is not immediate.

Maybe ixgbe is not calling netif_stop_all_queues() at quite the right
time?

Ben.

--=20
Ben Hutchings
When you say `I wrote a program that crashed Windows', people just stare ..=
.
and say `Hey, I got those with the system, *for free*'. - Linus Torvalds

--=-LJgsn8ZunbuBYNZdfF1J
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUyOcgue/yOyVhhEJAQqkCg/+OCt8JqHE0h+QqbavIb5lf/jJd+iDSKOZ
thPGqqcJqJcnGMPFi8eu5x4Wsokryh1NH48qDf0vdIsPsIyS7sptxk4yPSHnlgur
aT5FF4FOpVZ+x1oHTjU+wW6meWN8HgvmolqanZxK7Pt4MYHJRla+ZsziZyZ6WHnV
Arw8X2EIoTZFxdV3vfsjrBDxEWXg5ycd1tUSmvQCvd6aj5s3jNcczz2ebhFlkrpL
yEVznm/FGMq4vO/f62QEwAf170hImrR+0ibhuhyyPYGYpG2bA3U9EV2lnKPyxXdw
qLV5lpm++l8MQLhLAVlNn3T3k4mTnWfuKVCvZZMLBdSfabdAI/VWG+UCziPMsuYP
8n50qQtXuvkhqjHqurXX5RbgVfgDiqHmnrrAXY+z/hmUcGS1cs6u31o37JgLNkdo
VRWPDMMwiddvbP7jAjz0auK9O4R/6hNX4rlMR7eEQrENS/j4zcmsfdWJz1+8M31Q
0iYjJgkPy6Etc4ZVJVEZMp4a3MbQXcRyIFMlvvlsOKs646pdzvgRB5KoQOTcAaNM
MlEMrbKozz4nZKTy+pUlxbW5B9Kf2i3/2GlZPq7cvrt95Z5dupk3oxI4jRLiXHJo
QHg75lJ4ghMHruTkT0b445qjgaMFkxkr8dKmFezWRFxke6Gzydug5SVdDuN+fudp
XTeyR5rA7MA=
=d9zo
-----END PGP SIGNATURE-----

--=-LJgsn8ZunbuBYNZdfF1J--
