From: hiren panchasara <hiren@strugglingcoder.info>
Subject: Re: RACK not getting disabled
Date: Mon, 18 Sep 2017 14:29:52 -0700
Message-ID: <20170918212952.GC28186@strugglingcoder.info>
References: <20170918201428.GB28186@strugglingcoder.info>
 <1505769494.29839.34.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="hYooF8G/hrfVAmum"
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from strugglingcoder.info ([104.236.146.68]:63542 "EHLO
        mail.strugglingcoder.info" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750781AbdIRV3t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 17:29:49 -0400
Content-Disposition: inline
In-Reply-To: <1505769494.29839.34.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--hYooF8G/hrfVAmum
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 09/18/17 at 02:18P, Eric Dumazet wrote:
> On Mon, 2017-09-18 at 13:14 -0700, hiren panchasara wrote:
> > Hi all, I am trying to disable rack to see 3dupacks in action during
> > loss-detection but based on the pcap, I see that it's still trigger
> > loss-recovery on the first SACK (as if RACK is still enabled/active).
> >=20
> > Here is what I did to disable rack:
> > net.ipv4.tcp_recovery =3D 0
> >=20
> > I've also disabled metrics:
> > net.ipv4.tcp_no_metrics_save =3D 1=20
> > And also flushed existing entries with 'ip tcp_metrics flush' just to be
> > on a safer side.
> >=20
> > Not really relevant here but I've also switched to reno.
> >=20
> > I am on: 4.10.0-33-generic
> > pcap: https://transfer.sh/mfoiN/reno_no_rack.pcap
> >=20
> > What am I missing? I can provide any additional info.
> >=20
> > Cheers,
> > Hiren
>=20
>=20
> A single SACK can contains enough information to trigger a retransmit.

Bah, right. FACK!
>=20
> If you absolutely want to see the old 3 dupack in action, you also want
> to disable SACK.

I believe net.ipv4.tcp_fack =3D 0 would achieve that without disabling
sack.

Thanks for your help!
Cheers,
Hiren

--hYooF8G/hrfVAmum
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQF8BAABCgBmBQJZwDrOXxSAAAAAAC4AKGlzc3Vlci1mcHJAbm90YXRpb25zLm9w
ZW5wZ3AuZmlmdGhob3JzZW1hbi5uZXRBNEUyMEZBMUQ4Nzg4RjNGMTdFNjZGMDI4
QjkyNTBFMTU2M0VERkU1AAoJEIuSUOFWPt/lJAkH/iRac/5vhh6qmipiBUQ5WQl8
pAttZHu3XtNcKyHGgF/1r++hvu0z4KGmf4Mphtp0w/jxwLEtHsbLq+LdMCYovCzP
YtGz4WPQ6XLANoQdO6CEUTjdNM6DipbsUfhNIXxtBKYasRjJSoIJoOdLM531P6Vl
Hdurm0KkklzmHQdTyoUWSknXDPIk9UgvP1Ajsj5/HxM9YejldaZR0XXfsJ9uEqyv
EjnoDaLokKrTTvX6rZDggkBzQrnPtWO7XgdOxHjZVMhWt8AX3Pp/n5y2tPYnNK2p
HnUCvbs8QO0wegLquFKGRr2HXSGPQmwDSiVWX6h0Dy0RQaVLnuCfEQKRUEQC2Y0=
=9rPQ
-----END PGP SIGNATURE-----

--hYooF8G/hrfVAmum--
