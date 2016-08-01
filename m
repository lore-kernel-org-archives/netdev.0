From: Valdis.Kletnieks@vt.edu
Subject: Re: [PATCH v2] bpf: silence warnings when building kernel/bpf/core.c with W=1
Date: Mon, 01 Aug 2016 01:18:43 -0400
Message-ID: <28964.1470028723@turing-police.cc.vt.edu>
References: <23710.1470026010@turing-police.cc.vt.edu>
 <20160801044220.GA97382@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1470028723_2820P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound.smtp.vt.edu ([198.82.183.121]:55378 "EHLO
	omr1.cc.vt.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750879AbcHAFUr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2016 01:20:47 -0400
In-Reply-To: <20160801044220.GA97382@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1470028723_2820P
Content-Type: text/plain; charset=us-ascii

On Sun, 31 Jul 2016 21:42:22 -0700, Alexei Starovoitov said:

> and at least 2 other such patches for other files...
> Is there a single warning where -Woverride-init was useful?
> May be worth disabling this warning for the whole build?

There's a few other cases that *aren't* the "define the array to zero
and then build the entries from a list" form.

In particular, there's still 3 odd complaints:

drivers/ata/ahci.c:
drivers/ata/ahci.h:393:16: warning: initialized field overwritten [-Woverride-in
it]
  .can_queue  = AHCI_MAX_CMDS - 1,

drivers/block/drbd/drbd_main.c:
drivers/block/drbd/drbd_main.c:3767:22: warning: initialized field overwritten [
-Woverride-init]
   [P_RETRY_WRITE]  = "retry_write",

arch/x86/kernel/cpu/common.c:
./arch/x86/include/asm/page_64_types.h:22:21: warning: initialized field overwri
tten [-Woverride-init]
 #define DEBUG_STKSZ (PAGE_SIZE << DEBUG_STACK_ORDER)

The point of these patches is to make -Woverride-init *useful* - you'll never
spot 3 warnings in a flood of over 9,000 understood-and-ignored warnings.

Get rid of the 9,000 understood-and-ignored warnings, and then things that
probably *should* be looked at can be noticed.


--==_Exmh_1470028723_2820P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBV57bswdmEQWDXROgAQLeCw//T147oOqmQR8zPvKVVgGl2s+8vOkGDTjW
sL/0NFrvSAjZlTbh2mVN93rPa415acWYs9dWiuPdGgFSMoa7abU1PLQYEphMJCTZ
wZML8BfPs/GtSpuiFVvnjdOjeduG3PGPBuWdDC9/Dh8mLGI7hTpw/LN0eVZNjLKd
efFxq1eWLPvysgNs2iyHht4RMjtVXThe5aXgEOxMwmqQ09NOv0pep0oWYg2cHkBA
IJvdhsMsUNADaRJupTftvvyYfO/gPNI+5L+QglkvHpEeftfr5gQxX3TDrn+rdhvR
LraWu4sFmLSuaPBC3fCev7ZgQRte8KE4GIRz/NGgQ/i4s0zQJpQN2K1Na2wqKI45
l1k6mCCkGjsxAIkYmdrq2n0sDbb/epr01r3pfbuYfXW5sgumWLoP/H7a5aNdx7XL
y8y6u9IWQMNzFD6FbZUyqVy8YbiHI+5Z2tfctYUYik8TEUZ21y/LmtIgRg6yEJWq
fYJyWlPzGwzFqnDr5nrBwNPGHvaRsGHML5NvqKZh3mMMQcAm0pXWZbhFDtcdJ9uJ
dzzX/bQJieaOF8T8QQ9xSsMYNl1FEx7WuM7hoa1Gufbbo0bjToNeZkIKHjFFpAAB
VU4eA0G6AE7l12Ss0iUlNjIssvpvv+kidSrs+MgWdhRkn55C2Xvp4I9e5kpesbdA
Wl3z/IH6Cq4=
=OgP0
-----END PGP SIGNATURE-----

--==_Exmh_1470028723_2820P--
