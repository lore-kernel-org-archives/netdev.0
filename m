From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of the final tree
 (net-next tree related)
Date: Fri, 21 Sep 2012 11:37:49 +1000
Message-ID: <20120921113749.146a7b501463d70cda3dc268@canb.auug.org.au>
References: <20120920173622.2aa7209cd241a3945f4384d4@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__21_Sep_2012_11_37_49_+1000_wNJqj3MwOJCMRZws"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mika Westerberg <mika.westerberg@linux.intel.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20120920173622.2aa7209cd241a3945f4384d4@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__21_Sep_2012_11_37_49_+1000_wNJqj3MwOJCMRZws
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

On Thu, 20 Sep 2012 17:36:22 +1000 Stephen Rothwell <sfr@canb.auug.org.au> =
wrote:
>
> After merging the final tree, today's linux-next build (powerpc
> allyesconfig) failed like this:
>=20
> drivers/net/ethernet/i825xx/znet.c: In function 'hardware_init':
> drivers/net/ethernet/i825xx/znet.c:868:2: error: implicit declaration of =
function 'isa_virt_to_bus' [-Werror=3Dimplicit-function-declaration]
>=20
> Caused by commit 1d3ff76759b7 ("i825xx: znet: fix compiler warnings when
> building a 64-bit kernel").  Is there some Kconfig dependency missing (CO=
NFIG_ISA)?
>=20
> I have reverted that commit for today.

Today, I have added the following merge fix patch instead of reverting the
above (just until PowerPC can be fixed one way or the other).  I don't
know if you want to put this into the net-next tree, but it may be a
reasonable temporary measure.

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 21 Sep 2012 11:32:09 +1000
Subject: [PATCH] i825xx: znet: temporarily disable on PPC

due to build problems

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/ethernet/i825xx/Kconfig |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/i825xx/Kconfig b/drivers/net/ethernet/i82=
5xx/Kconfig
index fed5080..9fce38b 100644
--- a/drivers/net/ethernet/i825xx/Kconfig
+++ b/drivers/net/ethernet/i825xx/Kconfig
@@ -151,6 +151,7 @@ config SUN3_82586
 config ZNET
 	tristate "Zenith Z-Note support (EXPERIMENTAL)"
 	depends on EXPERIMENTAL && ISA_DMA_API
+	depends on !PPC
 	---help---
 	  The Zenith Z-Note notebook computer has a built-in network
 	  (Ethernet) card, and this is the Linux driver for it. Note that the
--=20
1.7.10.280.gaa39

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Fri__21_Sep_2012_11_37_49_+1000_wNJqj3MwOJCMRZws
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQW8TtAAoJEECxmPOUX5FE3msP/AmFP2NEVyZevD2rXmr8XBi0
02VMs4hFBR9uvQr3St+pG6rv22juutYn9m0Sd35x3LihYiiGVKgbHmPB6ckbnsF6
MtigP5KUclF6E3o0FVOS18N9WNof6Sd/PAqoYZoimMOqIeE95PTnXY3eLnQfXRBq
YXtLkEVRPPQUwLs3lIiCfFViSs+1aUb0oMobSUQiVVLwAaWVavhp/DUfi10YI862
uKuIhLLvvdDkFUfhwR2t5kGE3cO0OCRcK7sED6W2rB2OZj8Efv6o1PeWXu3M6BFv
e4Y96Nnlf5bLUELB5R321MyZmqGSGGxfjeNDAF32FgYrIDaXzRubQBSvtm5CGfYK
iMhSQ6s8yiy7OLoyjm/Svs4fj8QDrfSZmUAL+k93XvAN5SrERqjYnlPe5xZFKdzu
UYnvjsQ4GXc5q0A6KAxex/64NKgzz9BJ0ww8sfUl4ZcDC2UeBHxLoY7rCPg4dxx2
22Z/c14jsi1xizL+dSqaSENwcCYunTYzy42MD88/JW5XowSKgg0FNvkzhkfhmBd3
moLdhsouxU7YwbQlvHZXLUSbEtlCXzOaxJUprzuV4LRhYnqE9FmnhstC0nWN5VJB
r3JdcTXnj957V7UdHP8bMPiJ7maG43PJdAXCcUHnflpwcQlN8KEO6/YXWUSv1Hwa
sg00fVXrYKJf4JqW3DUE
=wLOi
-----END PGP SIGNATURE-----

--Signature=_Fri__21_Sep_2012_11_37_49_+1000_wNJqj3MwOJCMRZws--
