From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PowerPC] Next May 8 boot failure: OOPS during ibmveth
 moduleinit
Date: Tue, 12 May 2009 17:04:58 +1000
Message-ID: <20090512170458.39c4ffb7.sfr@canb.auug.org.au>
References: <20090508180251.f53f204e.sfr@canb.auug.org.au>
	<4A042B20.4090903@in.ibm.com>
	<20090508.125722.54378771.davem@davemloft.net>
	<20090508223332.GA4881@psychotron.englab.brq.redhat.com>
	<4A085B3D.5000806@in.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Tue__12_May_2009_17_04_58_+1000_OgMhgcPHONrnGr98"
Cc: Jiri Pirko <jpirko@redhat.com>, David Miller <davem@davemloft.net>,
	linux-next@vger.kernel.org, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
To: Sachin Sant <sachinp@in.ibm.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <4A085B3D.5000806@in.ibm.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__12_May_2009_17_04_58_+1000_OgMhgcPHONrnGr98
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

On Mon, 11 May 2009 22:37:09 +0530 Sachin Sant <sachinp@in.ibm.com> wrote:
>
> Jiri Pirko wrote:
> > Fri, May 08, 2009 at 09:57:22PM CEST, davem@davemloft.net wrote:
> >  =20
> >> From: Sachin Sant <sachinp@in.ibm.com>
> >> Date: Fri, 08 May 2009 18:22:48 +0530
> >>
> >>    =20
> >>> Todays Next failed to boot on a Power6 JS22 blade with following oops.
> >>>      =20
> >> Jiri, I suspect this might be your address list changes.
> >>
> >> Although that's just a guess.  But please take a look.
> >>    =20
> >
> > Hmm, only thing I see might cause the problem would be if calling __hw_=
addr_add
> > in dev_addr_init fails, then dev->dev_addr would contain zeroes (which =
looks
> > this is not the case). But in this case the oops would appear earlier (=
in
> > ibmveth_probe dev_addr memcpy).
> >
> > Will do the patch which checks the result to behave correctly in case o=
f oom
> > but this imho this wouldn't help. Strange, I will dig into this more to=
morrow.

Bisected down to:

commit f001fde5eadd915f4858d22ed70d7040f48767cf
Author: Jiri Pirko <jpirko@redhat.com>
Date:   Tue May 5 02:48:28 2009 +0000

    net: introduce a list of device addresses dev_addr_list (v6)

I can reproduce this at will on the last three linux-next trees.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Tue__12_May_2009_17_04_58_+1000_OgMhgcPHONrnGr98
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkoJH5oACgkQjjKRsyhoI8zPGgCgt2pJ4q6YoTA0CXSrn7j4oscz
2qgAnRK/QLZAkfEGjqSpmDF838IHJ8Yc
=IG2y
-----END PGP SIGNATURE-----

--Signature=_Tue__12_May_2009_17_04_58_+1000_OgMhgcPHONrnGr98--
