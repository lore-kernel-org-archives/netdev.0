From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: New "ip wait" subcommand for iproute2
Date: Wed, 30 Dec 2015 12:31:41 -0800
Message-ID: <20151230123141.3769ecbb@xeon-e3>
References: <20151228234751.GH47562@gradx.cs.jhu.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/oHAF8EzHlyjabtQ3x2Zao5y"; protocol="application/pgp-signature"
Cc: netdev@vger.kernel.org
To: Nathaniel W Filardo <nwf@cs.jhu.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:34713 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754008AbbL3Ubc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2015 15:31:32 -0500
Received: by mail-pf0-f180.google.com with SMTP id e65so93602211pfe.1
        for <netdev@vger.kernel.org>; Wed, 30 Dec 2015 12:31:32 -0800 (PST)
In-Reply-To: <20151228234751.GH47562@gradx.cs.jhu.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/oHAF8EzHlyjabtQ3x2Zao5y
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 28 Dec 2015 18:47:51 -0500
Nathaniel W Filardo <nwf@cs.jhu.edu> wrote:

> Hallo netdev@,
>=20
> I had occasion to want to programmatically wait for an interface to become
> available from within a shell script, but found there to be no off-the-sh=
elf
> tool for such a thing.  Could this patch be considered for inclusion as p=
art
> of iproute2?  It adds an "ip wait link" subcommand ("link" required in ca=
se
> someone wants to add things like "ip wait addr" or somesuch) based quite
> heavily on the ipmonitor.c file.
>=20
> For example, one might "ip wait link dev eth0 up" to wait for an interface
> of that name to appear (specifically, for a RTM_NEWLINK message).  "ip wa=
it
> link dev eth0 down" will wait for it to go away (RTM_DELLINK).
>=20
> This should be checkpatch clean, but please let me know if I missed
> something.
>=20
> Cheers,
> --nwf;
>


Thank you for your contribution, it looks useful.
Could you also update the man page?

> +static int accept_msg(const struct sockaddr_nl *who,
> +		      struct rtnl_ctrl_data *ctrl,
> +		      struct nlmsghdr *n, void *arg)
> +{
> +	int done =3D 0;
> +
> +	if (n->nlmsg_type =3D=3D RTM_NEWLINK || n->nlmsg_type =3D=3D RTM_DELLIN=
K) {
> +		if (wait_for =3D=3D n->nlmsg_type
> +		    && wait_for =3D=3D RTM_DELLINK
> +		    && ll_name_to_index(wait_dev) !=3D 0)
> +			done =3D 1;
> +
> +		ll_remember_index(who, n, NULL);
> +		if (verbose)
> +			print_linkinfo(who, n, stdout);
> +
> +		if (wait_for =3D=3D n->nlmsg_type
> +		    && wait_for =3D=3D RTM_NEWLINK
> +		    && ll_name_to_index(wait_dev) !=3D 0)
> +			done =3D 1;
> +	}
> +	if (done) {
> +		fflush(stdout);
> +		exit(0);

I don't think you need explicit fflush here. Stdio does it automatically.
Which means all the conditional(done) can be removed.

Have you considered how wait could be used with --batch option
to write a script?



--Sig_/oHAF8EzHlyjabtQ3x2Zao5y
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWhD8tAAoJEICnf2CVzeR+0p0QALOWvgC21S+m2lZI8DrqOqwQ
xw9gs6qH0evL3FG52HGgGNtJiuIkhrF4oqABiw/lkyFgdl0PLHsuo2op9/iyxdtc
qxZ5Vlkq+0KcmiWsoeziSz+9nUcExK6RyLIdvTdMeGdjLoUfPrE3uG6i/Svup4Xp
Mek3onBmLdglLtS9oAzo06BjfYeZqZZ8glI6YH0sChgqDWZZJScszkY+3PmlGd1B
Ydg6c+f8J5Ex9QPDt+d6WCkOSFCBWxTSM8CesalVeEaDcTxgZULZjer7BFjEfV6R
fikie4WSjzPoRxfr98QUDLZsHtnpIC9UDGLpTTY1dNVgI06Sq6O1CXu2GvTYTT2Z
BfFlo1gFlJja/6J61xyvuv8TZ+7+bPvigffBBJv/CRtzoMjJvAzUhszlmNFCfK2b
kfxkDlSfUaXLwzSMH349ctr5Z/xQyyIVgknbAHZAtZA4tkbW39/raanAellF/FUj
myXs1zpBGYW/LP5aAyFSQmshorv40Rd5dbeODzpfs5oSUMPFpfivw0OkP1UQ+j5j
m62LZC9K+BUbakGAO7tDJkrBcA20uZ43Bb5NvCLDWiZKgBe5lsx+YgMWZCD8i6nU
fORR20tgOy28g/S0z4G9FNCp7JpXBc/KMNmo/xnXn/zO6dSPX4wn4wN62Vo1fe1V
yjEuEaPO/OMVfuF5twWt
=R2zr
-----END PGP SIGNATURE-----

--Sig_/oHAF8EzHlyjabtQ3x2Zao5y--
