From: Andreas Schwab <schwab@suse.de>
Subject: Re: [PATCH 9/24] make atomic_read() behave consistently on ia64
Date: Fri, 10 Aug 2007 23:42:59 +0200
Message-ID: <jewsw3oyl8.fsf@sykes.suse.de>
References: <20070809135107.GA15985@shell.boston.redhat.com>
	<617E1C2C70743745A92448908E030B2A02213B3C@scsmsx411.amr.corp.intel.com>
	<46BCC1AF.5050204@redhat.com>
	<617E1C2C70743745A92448908E030B2A0224C777@scsmsx411.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Chris Snook" <csnook@redhat.com>, <linux-kernel@vger.kernel.org>,
	<linux-arch@vger.kernel.org>, <torvalds@linux-foundation.org>,
	<netdev@vger.kernel.org>, <akpm@linux-foundation.org>,
	<ak@suse.de>, <heiko.carstens@de.ibm.com>, <davem@davemloft.net>,
	<schwidefsky@de.ibm.com>, <wensong@linux-vs.org>,
	<horms@verge.net.au>, <wjiang@resilience.com>,
	<cfriesen@nortel.com>, <zlynx@acm.org>, <rpjday@mindspring.com>,
	<jesper.juhl@gmail.com>
To: "Luck, Tony" <tony.luck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:52351 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750994AbXHJVnN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2007 17:43:13 -0400
In-Reply-To: <617E1C2C70743745A92448908E030B2A0224C777@scsmsx411.amr.corp.intel.com>
	(Tony Luck's message of "Fri\, 10 Aug 2007 14\:19\:29 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Luck, Tony" <tony.luck@intel.com> writes:

>> That's distressing.  I'm about to resubmit with a volatile cast in=20
>> atomic_set as well, since people expect that behavior and I've been=20
>> shown a legitimate case where it could matter.  Does the assembly lo=
ok=20
>> right with that cast in atomic_set() as well?
>
> No.  With the casts to volatile in atomic_set and atomic64_set I
> still see places where ld8 is changed to ld4 + sign-extend.

Use atomic64_read to read an atomic64_t.

Signed-off-by: Andreas Schwab <schwab@suse.de>

diff --git a/include/asm-ia64/atomic.h b/include/asm-ia64/atomic.h
index 1fc3b83..50c2b83 100644
--- a/include/asm-ia64/atomic.h
+++ b/include/asm-ia64/atomic.h
@@ -55,7 +55,7 @@ ia64_atomic64_add (__s64 i, atomic64_t *v)
=20
 	do {
 		CMPXCHG_BUGCHECK(v);
-		old =3D atomic_read(v);
+		old =3D atomic64_read(v);
 		new =3D old + i;
 	} while (ia64_cmpxchg(acq, v, old, new, sizeof(atomic64_t)) !=3D old)=
;
 	return new;
@@ -83,7 +83,7 @@ ia64_atomic64_sub (__s64 i, atomic64_t *v)
=20
 	do {
 		CMPXCHG_BUGCHECK(v);
-		old =3D atomic_read(v);
+		old =3D atomic64_read(v);
 		new =3D old - i;
 	} while (ia64_cmpxchg(acq, v, old, new, sizeof(atomic64_t)) !=3D old)=
;
 	return new;

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4=
ED5
"And now for something completely different."
