From: "Jeremy M. Guthrie" <jeremy.guthrie@berbee.com>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Sun, 16 Jan 2005 10:22:27 -0600
Message-ID: <200501161022.30600.jeremy.guthrie@berbee.com>
References: <Pine.LNX.4.44.0501071416060.5818-100000@localhost.localdomain> <200501141326.29575.jeremy.guthrie@berbee.com> <16874.24305.461492.48668@robur.slu.se>
Reply-To: jeremy.guthrie@berbee.com
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2097987.pIz7SLg2Ap";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <16874.24305.461492.48668@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart2097987.pIz7SLg2Ap
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Sunday 16 January 2005 06:32 am, Robert Olsson wrote:
> Jeremy M. Guthrie writes:
>  > I actually upped the buffer count to 8192 buffers instead of 10k.
>  > Of the 74 samples I have thus far, 57 have been clean of errors.
>  > Most of the sample errors appear to be shortly after the cache flush.
>
>  I don't really believe in increasing RX buffers to this extent. We
> verified that you have CPU available and the drops occur when the timer
> based GC happens. Increasing buffers decreases overall performance and ad=
ds
> jitter.
I just took a look at my logs, the increase to the max on the card of 4K RX=
=20
buffers has stopped packet drops except during GC.  I agree, it isn't prett=
y=20
and it is not the solution I would like.  In the mean time, it has at least=
=20
stopped the 0.3% round-the-clock packet loss which I was seeing even at rat=
es=20
as low as 25K pps.

>  We saw also the timed based GC were taking the dst-entries from about
>  600k to 40k in one shot. I think this what we should look into. Just
>  GC is "work" also after GC a lot flows has to be recreated doing fib
>  lookup and creating new entries. We want to smoothen the GC process so
>  happen more frequent and does less work.
Agreed.  I went to the extreme because I can really see the % idle CPU.  If=
 I=20
am constantly setting up new flows then the % of free CPU shoots way down. =
=20
Minus the effects of GC, a larger flow table equates into free CPU. =20

>  Some time ago an "in-flow" GC (as opposed to timer based) was added to
>  the routing code look for cand in route.c. In setup like yours (and ours)
>  it would be better to relay on this process to a higher extent. Anyway
>  in /proc/sys/net/ipv4/route/ you have the files.
>  gc_elasticity, gc_interval, gc_thresh etc I would avoid gc_min_interval.
>  And you can play with your running system and for drops without causing
>  your users to much pain.
>  We save the patch for routing without route hash and GC until later,
Okay.  I will bring my interval down from an hour down to ten minutes and d=
o=20
further tuning.

=2D-=20

=2D-------------------------------------------------
Jeremy M. Guthrie        jeremy.guthrie@berbee.com
Senior Network Engineer        Phone: 608-298-1061
Berbee                           Fax: 608-288-3007
5520 Research Park Drive         NOC: 608-298-1102
Madison, WI 53711

--nextPart2097987.pIz7SLg2Ap
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBB6pTGqtjaBHGZBeURAolHAJ9v4xanafdTJ+Yq0YttRukYnwZKhwCfZpJA
xpmyP+BZdnankW3uBsExbKo=
=6h2g
-----END PGP SIGNATURE-----

--nextPart2097987.pIz7SLg2Ap--
