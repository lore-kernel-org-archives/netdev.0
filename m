From: hiren panchasara <hiren@strugglingcoder.info>
Subject: Re: tcpprobe display format for snd_nxt and snd_una
Date: Thu, 6 Apr 2017 15:16:45 -0700
Message-ID: <20170406221645.GP62406@strugglingcoder.info>
References: <20170405194009.GH62406@strugglingcoder.info>
 <20170406174531.4fca96b0@plumbers-lap.home.lan>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="cYG5ZC/RuVsIq1ir"
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from strugglingcoder.info ([104.236.146.68]:56472 "EHLO
        mail.strugglingcoder.info" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752587AbdDFWQp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 18:16:45 -0400
Content-Disposition: inline
In-Reply-To: <20170406174531.4fca96b0@plumbers-lap.home.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--cYG5ZC/RuVsIq1ir
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 04/06/17 at 05:45P, Stephen Hemminger wrote:
> On Wed, 5 Apr 2017 12:40:09 -0700
> hiren panchasara <hiren@strugglingcoder.info> wrote:
>=20
> > (New to linux and first-time poster so please guide me if needed.)
> > =20
> > Upon using tcpprobe I realized that it prints snd_nxt and snd_una as hex
> > which makes it harder to read and compare with tcpdump for example.
> > =20
> > Not sure if that is intentional. If not, a simple patch like this would
> > print them as decimals.
> > =20
> > [PATCH] Display snd_nxt and snd_una as decimals for better
> >  readability.
> > =20
> > ---
> >  net/ipv4/tcp_probe.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > =20
> > diff --git a/net/ipv4/tcp_probe.c b/net/ipv4/tcp_probe.c
> > index f6c50af..a8e66c1 100644
> > --- a/net/ipv4/tcp_probe.c
> > +++ b/net/ipv4/tcp_probe.c
> > @@ -191,7 +191,7 @@ static int tcpprobe_sprint(char *tbuf, int n)
> >                 =3D ktime_to_timespec64(ktime_sub(p->tstamp, tcp_probe.=
start));
> > =20
> >         return scnprintf(tbuf, n,
> > -                       "%lu.%09lu %pISpc %pISpc %d %#x %#x %u %u %u %u=
 %u\n",
> > +                       "%lu.%09lu %pISpc %pISpc %d %u %u %u %u %u %u %=
u\n",
> >                         (unsigned long)ts.tv_sec,
> >                         (unsigned long)ts.tv_nsec,
> >                         &p->src, &p->dst, p->length, p->snd_nxt, p->snd=
_una,
> > --
> > =20
> > Let me know if I am missing something obvious.
>=20
> The output of tcpprobe is intended for consumption by programs.
> Changing the output format would be considered a kernel ABI breakage which
> is something Linux tries not to do. Therefore I would prefer it
> not be changed.
Ah, I see.

> Sorry if this is inconvenient for you but breaking other
> users scripts would be a bigger problem.
No, I don't have any scripts depending on this. I just want to see this
o/p with naked eye and compare it with a pcap to see any possible
abnormalities of a "bad" connection. I guess I'd have to no write a
wrapper on top of this to achieve whhat

Can you point me to the programs/tools that consume this data? I am new
to Linux and want to learn tools that can help in troubleshooting. (In
FreeBSD land I can trivially dump this data with dtrace and I assume
something like that exists here too.)

I can always have a wrapper on top of this to do the conversion. Trivial
but inconvenient. :-)

>=20
> Also, your patch email is not formatted with subject [RFC] or [PATCH]
> and is missing signed-off-by.

Apologies for that. I'll make sure I do the right thing next time as
this looks like a non-starter because of ABI concerns.

Thanks for taking time and responding.
Cheers,
Hiren

--cYG5ZC/RuVsIq1ir
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQF8BAABCgBmBQJY5r5KXxSAAAAAAC4AKGlzc3Vlci1mcHJAbm90YXRpb25zLm9w
ZW5wZ3AuZmlmdGhob3JzZW1hbi5uZXRBNEUyMEZBMUQ4Nzg4RjNGMTdFNjZGMDI4
QjkyNTBFMTU2M0VERkU1AAoJEIuSUOFWPt/lb5EIAJFMLbH3Lhop7qUAlxF+tEkL
tcVmm7U0ass6N0KeZt7+f6aPUG9n75zhiTIEyxdGvSZPlL+Z4HkmljgHRG8VrA6s
lAyer+TsIYyG8m1gzXzaxDkxqooiDwZR0HUY3IJmcjdeJTbiwa8QGl8j9FR1Ps9K
fh094rOt8E/dFfN3V3qDVxKQg2TC0h8xGHyDUV3Zg9GG6pkVrTXtZ3H2OiRm2ltk
qobSOqK3ZwPaA15TtvvL5w8IVD3yHP4uqrNPY90t6/OJrI9zthB+a2z1xUijOI+O
CC2szaQxiv0f5huOXG9gxyVUBOoaDGl17OtIoN++ZPdUQdDzbo/XSctD/gQ4SEc=
=wFZF
-----END PGP SIGNATURE-----

--cYG5ZC/RuVsIq1ir--
