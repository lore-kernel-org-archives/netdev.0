From: Michal Vanco <vanco@satro.sk>
Subject: Re: 2.6.11 on AMD64 traps
Date: Thu, 10 Mar 2005 00:50:05 +0100
Message-ID: <200503100050.05582.vanco@satro.sk>
References: <200503081900.18686.vanco@satro.sk> <200503092217.01106.vanco@satro.sk> <422F8649.8050707@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1432720.iW0JzFStEf";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@oss.sgi.com
In-Reply-To: <422F8649.8050707@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart1432720.iW0JzFStEf
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Thursday 10 March 2005 00:27, Patrick McHardy wrote:
> Michal Vanco wrote:
> > On Wednesday 09 March 2005 22:05, Patrick McHardy wrote:
> >>>Sure. Can (or will) this ever be fixed to any usable state also with
> >>>netstat? Is this problem related only to AMD64?
> >>
> >>Maybe. To start dumping entries of an open hashed hash-table at a
> >>specific position we need to skip all entries before that position by
> >>walking over them. This results in quadratic time complexity. It might
> >>be possible to improve this by cacheing the last position in
> >>fib_iter_state even between ->stop() and ->start() calls and using
> >>generation IDs for invalidation.
>
> And here it is. Could you redo your timing-test with this patch please?

Wonderfull:

# time ip route show | wc -l; time netstat -rn | wc -l
155991

real    0m1.110s
user    0m0.441s
sys     0m1.100s
155991

real    0m1.435s
user    0m1.026s
sys     0m0.436s

It seems that netlink is still little bit faster than /proc, but it doesn't=
=20
make any sense in case like this.
Will this patch be included in future kernels?

Great job. Thank you for help.

Best regards,
=2D-=20
Ing. Michal Van=C4=8Do
Network Engineer
SATRO s.r.o.
e-mail: vanco@satro.sk

--nextPart1432720.iW0JzFStEf
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.0 (GNU/Linux)

iD8DBQBCL4utSBxxqpMaGkMRAqPHAJ4mGD7K/P+/Ay9JEcMzRMHMmmUv6ACgk3d2
aRMFyFDVbqG8s8dSMSmJgNc=
=Ep8t
-----END PGP SIGNATURE-----

--nextPart1432720.iW0JzFStEf--
