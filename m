From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the akpm tree
Date: Fri, 30 Sep 2011 15:32:55 +1000
Message-ID: <20110930153255.6e3a0d6dc7758b7fb5561fc6@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Fri__30_Sep_2011_15_32_55_+1000_bF/mBImnMkUa4T03"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Stephen Boyd <sboyd@codeaurora.org>,
	Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__30_Sep_2011_15_32_55_+1000_bF/mBImnMkUa4T03
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

After merging the akpm tree, today's linux-next build (x86_64 allmodconfig)
failed like this:

In file included from arch/x86/include/asm/uaccess.h:575:0,
                 from include/net/checksum.h:25,
                 from include/linux/skbuff.h:28,
                 from include/linux/icmpv6.h:82,
                 from net/compat.c:19:
In function 'copy_from_user',
    inlined from 'compat_sys_socketcall' at net/compat.c:793:20:
arch/x86/include/asm/uaccess_64.h:64:26: error: call to 'copy_from_user_ove=
rflow' declared with attribute error: copy_from_user() buffer size is not p=
rovably correct

Caused by commit 15e19cbbbf2a ("x86: implement strict user copy checks
for x86_64") when built with gcc 4.6.0.  This does not fail when built
with 4.5.2.

The problem here is that the length parameter to copy_from_user() is
obtained by indexing into an array of sizes.  Making the array const
does not help (obviously, since the index is not known at compile time
anyway).

Maybe I need a newer compiler.  For today I have gone back to my 4.5.2
compiler.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Fri__30_Sep_2011_15_32_55_+1000_bF/mBImnMkUa4T03
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJOhVSHAAoJEDMEi1NhKgbsoYEH/0NvL38n9t3BG4bRkl8WwYmg
ItNnlwLCzrvxD4ULwytwBmPxKCKsybJiJSQVpf1Q4LWWCWV7JtTraLcSZJ8SQjSf
BGK8SVNeN+a2GrNW9ao5J5yA9dbzyVuCZnFi4DdowErDJOJAnhyyQFo+BXadBVM/
81j06oIuKUJz8JfxBfhLSgHOKjKk8U+fTsl7rJ4P8Nsk9bJltKJm9/nfzUMn3SB7
gopRGuF5UW51CPs7kAR3EbvQ5bAezCagnTqo606ynwcp/sEN3r1ltA5FnM6ETQq0
XlYYX59C2VNhzvBaAJr2FNEqsfua+pQ+xPOTEFnw9gq77DUDQkft9vORmvIox7k=
=1/PB
-----END PGP SIGNATURE-----

--Signature=_Fri__30_Sep_2011_15_32_55_+1000_bF/mBImnMkUa4T03--
