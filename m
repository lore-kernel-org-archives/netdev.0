From: "D. S. Ljungmark" <spider@takeit.se>
Subject: Re: ipv6 : Don't reduce hop limit below current value
Date: Wed, 25 Mar 2015 00:36:38 +0100
Message-ID: <1427240198.3276.8.camel@takeit.se>
References: <1427232969.3276.4.camel@takeit.se>
	 <20150324.180610.1598116015739871982.davem@davemloft.net>
Reply-To: ljungmark@modio.se
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-TuEHpQ0uK3ID/VFsL2gp"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:36303 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751842AbbCXXgn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 19:36:43 -0400
Received: by labe2 with SMTP id e2so6668329lab.3
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 16:36:41 -0700 (PDT)
In-Reply-To: <20150324.180610.1598116015739871982.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-TuEHpQ0uK3ID/VFsL2gp
Content-Type: multipart/mixed; boundary="=-6InRY2lx3uKSdosWLdhX"


--=-6InRY2lx3uKSdosWLdhX
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On tis, 2015-03-24 at 18:06 -0400, David Miller wrote:
> From: "D. S. Ljungmark" <spider@takeit.se>
> Date: Tue, 24 Mar 2015 22:36:09 +0100
>=20
> > +		/*	Only set hop_limit on the interface if it is higher than
> > +		*	the current hop_limit.
> > +		 */
>=20
> Comments in the networking should be of the form:
>=20
> 	/* Like
> 	 * this.
> 	 */

Not sure if your complaint was about the misaligned *, or that there was
a tab char after the comment start rather than a space.

Adjusted both and re-sending.



And there was a comment about quoting the relevant IETF standard,

RFC 3756, Section 4.2.7, "Parameter Spoofing"


   1.  The attacker includes a Current Hop Limit of one or another small
       number which the attacker knows will cause legitimate packets to
       be dropped before they reach their destination.
<snip>

   As an example, one possible approach to mitigate this threat is to
   ignore very small hop limits.  The nodes could implement a
   configurable minimum hop limit, and ignore attempts to set it below
   said limit.


This patch basically treats the current interface hop limit as the
threshold to use.=20

//D.S.


--=-6InRY2lx3uKSdosWLdhX
Content-Disposition: attachment;
	filename="0001-ipv6-Don-t-reduce-hop-limit-for-an-interface.patch"
Content-Type: text/x-patch;
	name="0001-ipv6-Don-t-reduce-hop-limit-for-an-interface.patch";
	charset="UTF-8"
Content-Transfer-Encoding: base64

RnJvbSA4YWJiOWNhNTk1ZjgzYWU0ZjQzM2RiZTJiMDIyYzllMTZhMGNiYzM5IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiAiRC5TLiBManVuZ21hcmsiIDxzcGlkZXJAc2t1Z2dvci5zZT4K
RGF0ZTogVHVlLCAyNCBNYXIgMjAxNSAyMjoxODo0NyArMDEwMApTdWJqZWN0OiBbUEFUQ0hdIGlw
djY6IERvbid0IHJlZHVjZSBob3AgbGltaXQgZm9yIGFuIGludGVyZmFjZQoKQSBsb2NhbCByb3V0
ZSBtYXkgaGF2ZSBhIGxvd2VyIGhvcF9saW1pdCBzZXQgdGhhbiBnbG9iYWwgcm91dGVzIGRvLgpT
ZWUgUkZDIDM3NTYgU2VjdGlvbiA0LjIuNwoKU2lnbmVkLW9mZi1ieTogRC5TLiBManVuZ21hcmsg
PGxqdW5nbWFya0Btb2Rpby5zZT4KLS0tCiBuZXQvaXB2Ni9uZGlzYy5jIHwgOSArKysrKysrKy0K
IDEgZmlsZSBjaGFuZ2VkLCA4IGluc2VydGlvbnMoKyksIDEgZGVsZXRpb24oLSkKCmRpZmYgLS1n
aXQgYS9uZXQvaXB2Ni9uZGlzYy5jIGIvbmV0L2lwdjYvbmRpc2MuYwppbmRleCA0NzFlZDI0Li4x
NGVjZGFmIDEwMDY0NAotLS0gYS9uZXQvaXB2Ni9uZGlzYy5jCisrKyBiL25ldC9pcHY2L25kaXNj
LmMKQEAgLTEyMTgsNyArMTIxOCwxNCBAQCBzdGF0aWMgdm9pZCBuZGlzY19yb3V0ZXJfZGlzY292
ZXJ5KHN0cnVjdCBza19idWZmICpza2IpCiAJaWYgKHJ0KQogCQlydDZfc2V0X2V4cGlyZXMocnQs
IGppZmZpZXMgKyAoSFogKiBsaWZldGltZSkpOwogCWlmIChyYV9tc2ctPmljbXBoLmljbXA2X2hv
cF9saW1pdCkgewotCQlpbjZfZGV2LT5jbmYuaG9wX2xpbWl0ID0gcmFfbXNnLT5pY21waC5pY21w
Nl9ob3BfbGltaXQ7CisJCS8qIE9ubHkgc2V0IGhvcF9saW1pdCBvbiB0aGUgaW50ZXJmYWNlIGlm
IGl0IGlzIGhpZ2hlciB0aGFuCisJCSAqIHRoZSBjdXJyZW50IGhvcF9saW1pdC4KKwkJICovCisJ
CWlmIChpbjZfZGV2LT5jbmYuaG9wX2xpbWl0IDwgcmFfbXNnLT5pY21waC5pY21wNl9ob3BfbGlt
aXQpIHsKKwkJCWluNl9kZXYtPmNuZi5ob3BfbGltaXQgPSByYV9tc2ctPmljbXBoLmljbXA2X2hv
cF9saW1pdDsKKwkJfSBlbHNlIHsKKwkJCU5EX1BSSU5USygyLCB3YXJuLCAiUkE6IEdvdCByb3V0
ZSBhZHZlcnRpc2VtZW50IHdpdGggbG93ZXIgaG9wX2xpbWl0IHRoYW4gY3VycmVudFxuIik7CisJ
CX0KIAkJaWYgKHJ0KQogCQkJZHN0X21ldHJpY19zZXQoJnJ0LT5kc3QsIFJUQVhfSE9QTElNSVQs
CiAJCQkJICAgICAgIHJhX21zZy0+aWNtcGguaWNtcDZfaG9wX2xpbWl0KTsKLS0gCjIuMS4wCgo=


--=-6InRY2lx3uKSdosWLdhX--

--=-TuEHpQ0uK3ID/VFsL2gp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCAAGBQJVEfUGAAoJEPzDdnREnjz8c0MP/1zJHZSIfn2lj8uRsnJwCnEk
Ygn9kkCML5BTA9rTJA3I1xDJr1pi17Ig/u70MPgb3+cV2/mm0B7IYDpxcxdi7+4t
9yuazKCXMIDmHeosen/MHlLu2S5f5iYHkikMm3IgmQW+qXzmUCD6IpxCq9OG0DpX
R5AaCe5bym8rXB4XMxb5L+WmRDlC/n/ZJQrdHGVv30PaK4lSTgcAPRYTOKWEPR+9
HpzxaNosm6nu+nkUYIdrp6QCuEc9LfRO5zn4YDZA6SuuWG73zTgI6A9Q48AeBJjZ
sLfx8jFqWl4IVAX9gLehbW00iqRzanXn2mzc6fZdugszTRF3/mxET/j2s86fwcVy
cvxJ0f9Zv+NcdDCbmA2aSRK47dC3n3v4kgba4F3OtFpYobgELG68hut7o1EgSdvU
z0o2XFnIHZOpvSaVXaINGWVUaOK7EoRGl+AZnh9XiuQlFySaXMlmvhDcr4yT52/N
ZbmfIsXoYZakjchsRLsZLEOregQIA36esr/jcXHp/x7HeWO29+RPgkpTLqdSqPKM
zyD8kh9E5jG6bwGjvMRAPbzOT4rXOqbf5qXdfjoFXnvQ0lcsTwkwcOPT7O2cF8tJ
Y51RmaOQhdXgWYEO8/5LruEC6yO+qzM+WZycFI9rVE//0XJ3COFw07oxm1KbxFmq
yGr6uTSsftLrOA46qXM0
=XsuO
-----END PGP SIGNATURE-----

--=-TuEHpQ0uK3ID/VFsL2gp--
