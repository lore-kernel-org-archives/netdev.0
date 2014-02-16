From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] ss: Add support for retrieving SELinux contexts
Date: Sun, 16 Feb 2014 13:18:10 +0000
Message-ID: <1392556690.15615.97.camel@deadeye.wl.decadent.org.uk>
References: <1392391214-14547-1-git-send-email-richard_c_haines@btinternet.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-YcR0awmDqCDHO6bXVpEz"
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov
To: Richard Haines <richard_c_haines@btinternet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:35915 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751822AbaBPNST (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Feb 2014 08:18:19 -0500
In-Reply-To: <1392391214-14547-1-git-send-email-richard_c_haines@btinternet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-YcR0awmDqCDHO6bXVpEz
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-02-14 at 15:20 +0000, Richard Haines wrote:
> The process SELinux contexts can be added to the output using the -Z
> option. Using the -z option will show the process and socket contexts (se=
e
> the man page for details).
> For netlink sockets: if valid process show process context, if pid =3D 0
> show kernel initial context, if unknown show "not available".
>=20
> Signed-off-by: Richard Haines <richard_c_haines@btinternet.com>
> ---
>  configure     |  16 +++
>  man/man8/ss.8 |  34 ++++++
>  misc/Makefile |  12 ++
>  misc/ss.c     | 375 ++++++++++++++++++++++++++++++++++++++++++++++++++--=
------
>  4 files changed, 387 insertions(+), 50 deletions(-)
>=20
> diff --git a/configure b/configure
> index da01c19..854837e 100755
> --- a/configure
> +++ b/configure
> @@ -231,6 +231,19 @@ EOF
>      rm -f $TMPDIR/ipsettest.c $TMPDIR/ipsettest
>  }
> =20
> +check_selinux()
> +# SELinux is a compile time option in the ss utility
> +{
> +	SELINUX_LIB=3D$(${PKG_CONFIG} --silence-errors libselinux --libs)
> +	if [ -n "$SELINUX_LIB" ]

This should be just:
	if pkg-config libselinux --exists

> +	then
> +	echo "HAVE_SELINUX:=3Dy" >>Config
> +	echo "yes"
> +    else
> +	echo "no"
> +	fi
> +}
[...]
> --- a/misc/Makefile
> +++ b/misc/Makefile
> @@ -8,6 +8,18 @@ include ../Config
>  all: $(TARGETS)
> =20
>  ss: $(SSOBJ)
> +ifeq ($(HAVE_SELINUX),y)
> +	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(SSOBJ) $(LDLIBS) -lselinux

This should use the output of 'pkg-config libselinux --libs'.

> +else
> +	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(SSOBJ) $(LDLIBS)
> +endif
> +
> +ss.o: ss.c
> +ifeq ($(HAVE_SELINUX),y)
> +	$(CC) $(CFLAGS) -DHAVE_SELINUX -c $+

This should use the output of 'pkg-config libselinux --cflags'.

> +else
> +	$(CC) $(CFLAGS) -c $+
> +endif
[...]

Ben.

--=20
Ben Hutchings
Any sufficiently advanced bug is indistinguishable from a feature.

--=-YcR0awmDqCDHO6bXVpEz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUwC6kue/yOyVhhEJAQrQxQ/+K85gJR4yLa2gZ9JsDsizWOHY8XSB1zq0
jaYICqhjN0XXyUPRQtfTDTKqXLgURZIQSFk4LmOqpIfaTENxqSPntloW7ORCG92L
Fr0215p3almKuPWcJ6KnI9F/EdlXVUMoUIZ4fdyg+yygZyVG+ZK47PLyS1KJLVSg
P+wxpGPMrYtJxdYFflyxjkf7f7CIpSkITQl3JkrkRD6jtlJ6hldRoyQy8cIWaR75
lc9aHB7GNAiMrCR+WhbdFEwndDFnaA+7Ls7SJ3I8IRPKupGluHV2nZphxR2c0fRE
Zo9ylqbwzlERV7P3cjpjEHkYL+Wv2MldhdLzUxBSrI1KCxIIoBg+YVYIMAxRmZIG
uGE6xW110CvyI5K2nQY8IQP96xYUDxnZ6N78HZMihlQAWqvoMXSEvffsYUlhbTs8
/nD1tb11vr/TnYGkVmA9GtQFrPm0T43OsJAcQ52kg3xquQ7BGj+7ihK292h6nY9W
QgYNNiND6lLabUNgeFBbXl5q2on6lWZwmUvspxlpkzIzLBlU6/4gcG8NcFNpyhU3
yyeVLHXQAWkK9sEHEOteHZerm83suzRdL/Y+/A9WEQfj38UBZGHAmuFI/lC7gRD/
SlhIsXgVf0vCiKsX9ag+rPCzpSDaOSKSmgP+lhnuSqQhsKmBL+WynqHcbi0BN/ZB
LkyHDO++F1o=
=Fe/D
-----END PGP SIGNATURE-----

--=-YcR0awmDqCDHO6bXVpEz--
