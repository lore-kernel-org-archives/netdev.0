From: hiren panchasara <hiren@strugglingcoder.info>
Subject: Re: RACK not getting disabled
Date: Mon, 18 Sep 2017 14:45:09 -0700
Message-ID: <20170918214509.GD28186@strugglingcoder.info>
References: <20170918201428.GB28186@strugglingcoder.info>
 <1505769494.29839.34.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170918212952.GC28186@strugglingcoder.info>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="g7w8+K/95kPelPD2"
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from strugglingcoder.info ([104.236.146.68]:60975 "EHLO
        mail.strugglingcoder.info" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750925AbdIRVpG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 17:45:06 -0400
Content-Disposition: inline
In-Reply-To: <20170918212952.GC28186@strugglingcoder.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--g7w8+K/95kPelPD2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 09/18/17 at 02:29P, hiren panchasara wrote:
> On 09/18/17 at 02:18P, Eric Dumazet wrote:
> > On Mon, 2017-09-18 at 13:14 -0700, hiren panchasara wrote:
> > > Hi all, I am trying to disable rack to see 3dupacks in action during
> > > loss-detection but based on the pcap, I see that it's still trigger
> > > loss-recovery on the first SACK (as if RACK is still enabled/active).
> > >=20
> > > Here is what I did to disable rack:
> > > net.ipv4.tcp_recovery =3D 0
> > >=20
> > > I've also disabled metrics:
> > > net.ipv4.tcp_no_metrics_save =3D 1=20
> > > And also flushed existing entries with 'ip tcp_metrics flush' just to=
 be
> > > on a safer side.
> > >=20
> > > Not really relevant here but I've also switched to reno.
> > >=20
> > > I am on: 4.10.0-33-generic
> > > pcap: https://transfer.sh/mfoiN/reno_no_rack.pcap
> > >=20
> > > What am I missing? I can provide any additional info.
> > >=20
> > > Cheers,
> > > Hiren
> >=20
> >=20
> > A single SACK can contains enough information to trigger a retransmit.
>=20
> Bah, right. FACK!
> >=20
> > If you absolutely want to see the old 3 dupack in action, you also want
> > to disable SACK.
>=20
> I believe net.ipv4.tcp_fack =3D 0 would achieve that without disabling
> sack.

Ah, what you probably meant was that this could still be < 3 dupacks
triggering loss-recovery based on reordering.

I believe I got what I was looking for.

Thanks a ton,
Hiren

--g7w8+K/95kPelPD2
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQF8BAABCgBmBQJZwD5iXxSAAAAAAC4AKGlzc3Vlci1mcHJAbm90YXRpb25zLm9w
ZW5wZ3AuZmlmdGhob3JzZW1hbi5uZXRBNEUyMEZBMUQ4Nzg4RjNGMTdFNjZGMDI4
QjkyNTBFMTU2M0VERkU1AAoJEIuSUOFWPt/lMYkH/3Ym7SZbh3Wlp/fbM+kdZogH
W5ICJ+2IUU2hgrFEiuGL34uQJAxrNIR6A5K9dUt/fb3gUla+OGdSjVQCvBI5sXw9
thVtBYSJU7CYM7h2arTF4svnyr6v8pfxsIF7mwY98kATzr+aRvCV0LlVMlq2HdI6
CEfQ+20K3j8Iyq4vteP+RQGTtPtgR1lkbj7PcTRxtJm2Jq139UoO+ioJsM4UENwK
QGhB9FxpXEJRdYa7FqLwIEKXRRFDUWRulmECdCd8+l0eE5NTNmnQ+br6jicwDr6y
S9DaB8idtmPKGhdo5EDUYJ07QpzInDnHhuT0gixl0FHGzfqVXL9bTHDnEUiIDoM=
=ZyPY
-----END PGP SIGNATURE-----

--g7w8+K/95kPelPD2--
