From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCHv5 2/2] memory barrier: adding smp_mb__after_lock
Date: Fri, 3 Jul 2009 11:24:38 +0200
Message-ID: <20090703092438.GE3902@elte.hu>
References: <20090703081219.GE2902@jolsa.lab.eng.brq.redhat.com> <20090703081445.GG2902@jolsa.lab.eng.brq.redhat.com> <20090703090606.GA3902@elte.hu> <4A4DCD54.1080908@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Olsa <jolsa@redhat.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	htejun@gmail.com, jarkao2@gmail.com, oleg@redhat.com,
	davidel@xmailserver.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:44812 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752434AbZGCJYz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Jul 2009 05:24:55 -0400
Content-Disposition: inline
In-Reply-To: <4A4DCD54.1080908@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Ingo Molnar a =E9crit :
> > * Jiri Olsa <jolsa@redhat.com> wrote:
> >=20
> >> +++ b/arch/x86/include/asm/spinlock.h
> >> @@ -302,4 +302,7 @@ static inline void __raw_write_unlock(raw_rwlo=
ck_t *rw)
> >>  #define _raw_read_relax(lock)	cpu_relax()
> >>  #define _raw_write_relax(lock)	cpu_relax()
> >> =20
> >> +/* The {read|write|spin}_lock() on x86 are full memory barriers. =
*/
> >> +#define smp_mb__after_lock() do { } while (0)
> >=20
> > Two small stylistic comments, please make this an inline function:
> >=20
> > static inline void smp_mb__after_lock(void) { }
> > #define smp_mb__after_lock
> >=20
> > (untested)
> >=20
> >> +/* The lock does not imply full memory barrier. */
> >> +#ifndef smp_mb__after_lock
> >> +#define smp_mb__after_lock() smp_mb()
> >> +#endif
> >=20
> > ditto.
> >=20
> > 	Ingo
>=20
> This was following existing implementations of various smp_mb__??? he=
lpers :
>=20
> # grep -4 smp_mb__before_clear_bit include/asm-generic/bitops.h
>=20
> /*
>  * clear_bit may not imply a memory barrier
>  */
> #ifndef smp_mb__before_clear_bit
> #define smp_mb__before_clear_bit()      smp_mb()
> #define smp_mb__after_clear_bit()       smp_mb()
> #endif

Did i mention that those should be fixed too? :-)

	Ingo
