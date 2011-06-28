From: <Shyam_Iyer@Dell.com>
Subject: RE: [PATCH] [net][bna] Fix call trace when interrupts are disabled
 while sleeping function kzalloc is called
Date: Tue, 28 Jun 2011 21:59:32 +0530
Message-ID: <DBFB1B45AF80394ABD1C807E9F28D1570453626FF0@BLRX7MCDC203.AMER.DELL.COM>
References: <1309206092-23064-1-git-send-email-shyam_iyer@dell.com>
 <20110627.160706.1453191829412045606.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="_002_DBFB1B45AF80394ABD1C807E9F28D1570453626FF0BLRX7MCDC203A_"
Cc: <netdev@vger.kernel.org>, <rmody@brocade.com>, <ddutt@brocade.com>
To: <davem@davemloft.net>, <shyam.iyer.t@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60ps301.us.dell.com ([143.166.148.206]:19085 "EHLO
	ausc60ps301.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757151Ab1F1QcI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2011 12:32:08 -0400
In-Reply-To: <20110627.160706.1453191829412045606.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--_002_DBFB1B45AF80394ABD1C807E9F28D1570453626FF0BLRX7MCDC203A_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

(My replies bounced of netdev for some reason..resending)

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Monday, June 27, 2011 7:07 PM
> To: shyam.iyer.t@gmail.com
> Cc: netdev@vger.kernel.org; rmody@brocade.com; ddutt@brocadel.com;
> Iyer, Shyam
> Subject: Re: [PATCH] [net][bna] Fix call trace when interrupts are
> disabled while sleeping function kzalloc is called
>=20
> From: Shyam Iyer <shyam.iyer.t@gmail.com>
> Date: Mon, 27 Jun 2011 16:21:32 -0400
>=20
> > The kzalloc sleeps and disabling interrupts(spin_lock_irqsave)
> > causes oops like the one.
>=20
> What if ->cfg_flags changes while you have dropped the lock?
>=20
> If the lock doesn't protect those flags, what was it being
> taken for in the first place?

Oops yes!

Here is try 2.

I found that I had to initialize the flags variable outside the spin_lock_i=
rqsave in the following way to fix the problem. The sleeping kzalloc functi=
on is in fact in the request_threaded_irq call which allocates the irq hand=
ler function and its flags arguments.

Attached patch fixes the issue.

--_002_DBFB1B45AF80394ABD1C807E9F28D1570453626FF0BLRX7MCDC203A_
Content-Type: application/octet-stream;
	name="0001-Fix-call-trace-in-request_irq.patch"
Content-Description: 0001-Fix-call-trace-in-request_irq.patch
Content-Disposition: attachment;
	filename="0001-Fix-call-trace-in-request_irq.patch"; size=1042;
	creation-date="Tue, 28 Jun 2011 16:27:05 GMT";
	modification-date="Tue, 28 Jun 2011 14:07:44 GMT"
Content-Transfer-Encoding: base64

RnJvbSAxZDQ2ZjE4NDdmYzAwMGQzMzVmM2IzZTc4NzViYTg4YTM2MDE3NGE0IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBTaHlhbSBJeWVyIDxzaHlhbV9peWVyQGRlbGwuY29tPgpEYXRl
OiBUdWUsIDI4IEp1biAyMDExIDEwOjAyOjEzIC0wNDAwClN1YmplY3Q6IFtQQVRDSF0gRml4IGNh
bGwgdHJhY2UgaW4gcmVxdWVzdF9pcnEuCgpTaWduZWQtb2ZmLWJ5OiBTaHlhbSBJeWVyIDxzaHlh
bV9peWVyQGRlbGwuY29tPgotLS0KIGRyaXZlcnMvbmV0L2JuYS9ibmFkLmMgfCAgICAzICstLQog
MSBmaWxlcyBjaGFuZ2VkLCAxIGluc2VydGlvbnMoKyksIDIgZGVsZXRpb25zKC0pCgpkaWZmIC0t
Z2l0IGEvZHJpdmVycy9uZXQvYm5hL2JuYWQuYyBiL2RyaXZlcnMvbmV0L2JuYS9ibmFkLmMKaW5k
ZXggN2QyNWE5Ny4uZDRlODY3MiAxMDA2NDQKLS0tIGEvZHJpdmVycy9uZXQvYm5hL2JuYWQuYwor
KysgYi9kcml2ZXJzL25ldC9ibmEvYm5hZC5jCkBAIC0xMTExLDcgKzExMTEsNyBAQCBibmFkX21i
b3hfaXJxX2FsbG9jKHN0cnVjdCBibmFkICpibmFkLAogCQkgICAgc3RydWN0IGJuYV9pbnRyX2lu
Zm8gKmludHJfaW5mbykKIHsKIAlpbnQgCQllcnIgPSAwOwotCXVuc2lnbmVkIGxvbmcgCWZsYWdz
OworCXVuc2lnbmVkIGxvbmcgCWZsYWdzID0gMDsKIAl1MzIJaXJxOwogCWlycV9oYW5kbGVyX3Qg
CWlycV9oYW5kbGVyOwogCkBAIC0xMTI1LDcgKzExMjUsNiBAQCBibmFkX21ib3hfaXJxX2FsbG9j
KHN0cnVjdCBibmFkICpibmFkLAogCWlmIChibmFkLT5jZmdfZmxhZ3MgJiBCTkFEX0NGX01TSVgp
IHsKIAkJaXJxX2hhbmRsZXIgPSAoaXJxX2hhbmRsZXJfdClibmFkX21zaXhfbWJveF9oYW5kbGVy
OwogCQlpcnEgPSBibmFkLT5tc2l4X3RhYmxlW2JuYWQtPm1zaXhfbnVtIC0gMV0udmVjdG9yOwot
CQlmbGFncyA9IDA7CiAJCWludHJfaW5mby0+aW50cl90eXBlID0gQk5BX0lOVFJfVF9NU0lYOwog
CQlpbnRyX2luZm8tPmlkbFswXS52ZWN0b3IgPSBibmFkLT5tc2l4X251bSAtIDE7CiAJfSBlbHNl
IHsKLS0gCjEuNy41LjQKCg==

--_002_DBFB1B45AF80394ABD1C807E9F28D1570453626FF0BLRX7MCDC203A_--
