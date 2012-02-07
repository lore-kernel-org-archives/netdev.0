From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] skbuff: Add new tc classify variable
Date: Tue, 7 Feb 2012 13:45:53 -0800
Message-ID: <20120207134553.220a1da5@nehalam.linuxnetplumber.net>
References: <1328639948-25232-1-git-send-email-siwu@hrz.tu-chemnitz.de>
	<20120207110522.70663963@nehalam.linuxnetplumber.net>
	<20120207195729.GA26533@pandem0nium>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA256;
 boundary="Sig_/1iaYM..SHwr59JxuCqjCLRc"; protocol="application/pgp-signature"
Cc: netdev@vger.kernel.org
To: Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36969 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756637Ab2BGVp4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Feb 2012 16:45:56 -0500
In-Reply-To: <20120207195729.GA26533@pandem0nium>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/1iaYM..SHwr59JxuCqjCLRc
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 7 Feb 2012 20:57:29 +0100
Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de> wrote:

> On Tue, Feb 07, 2012 at 11:05:22AM -0800, Stephen Hemminger wrote:
> > On Tue,  7 Feb 2012 19:39:08 +0100
> > Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de> wrote:
> >=20
> > I don't understand why this is better, we already have mark to do this.
> > Your method saves adding a tc filter to map mark to classid, but that i=
s hardly
> > a huge burden.
>=20
> Unfortunately, it is. We have previously built our trees by setting marks=
 with iptables
> and matching the masks with tc and the u32 matcher, but we got a rather b=
ig performance
> impact as soon as the number of users grow. The target platform are WiFi =
access points.
> By using the proposed patch, the performance stays nearly constant at a g=
rowing number
> of users.

The problem then is not the use of marks but having to add a filter rule for
each mark. We need something like u32 hash but for marks to build a table
of mark -> class id.  The current method uses a linear list of filter rules,
which is an obvious bottleneck with lots of classes.

--Sig_/1iaYM..SHwr59JxuCqjCLRc
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJPMZuRAAoJEICnf2CVzeR+RWgP/jb3Pn1bvYvSSZVFXS5auDHE
dc/eDfEgS1nnSl5M/5PwsRc/5mSBRWEfYdMPqb760NPmlmuSeThpqBsCROItWQo2
e+OLuS1OgrxqySHB1nM21y8LhDvUpU4Dw6Na6/jdiIooa609iLaFl8FCQmQxptyc
f/t+/jnCgrGBmZVQgWcIYSk599ttClXj+MHCUkIN28ljPD8GrGpsA06Gd42onxhP
5djXm/FTaaY2i1tlj3ienHPvhHCi/ePbkF5zU0xeXR320WtS3rFCTxb+fEcXRKFe
Eut62YjEBg2OJHh0x6RxFadC+1sg0G1m6baxbbo5MaHHTZ+IzA5Tpw/V2dk18MXy
A9eYbpbC3cPlx4bAE1WoTpT5WS8E7qNaw/Mrm009RP6huY0EK/HwRDFaxI2CzBWC
7+VX2jqe0RPsA8j8PWO0/2oDqa/efK0j1ZCUctG6/CoYg/1RcRjSSWebeKwxgWOx
XBuaFY9g3ddwr7fc7okA8XOvS1gWhexdxbOP7SHCl8rpupg+HRmV/vMfCpyLiRrN
9bEFiXQob+O00fBEi3TwZ9WSsr+AuFi566A0IlQBzVz5TMd/M0QdFA7FGCkjlSfc
JgtcwoOFjFknMo8E9MxZGYOhkU+yOfHt+hGLd7VUvL5Yt1w7Ng5B4ftDATCUMUuf
7IffB00Qw0T3KUlmHKi3
=4ltU
-----END PGP SIGNATURE-----

--Sig_/1iaYM..SHwr59JxuCqjCLRc--
