From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] x86: fix and improve cmpxchg_double{,_local}()
Date: Tue, 03 Jan 2012 18:31:39 +0100
Message-ID: <1325611899.2320.111.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4F01F12A020000780006A19B@nat28.tlf.novell.com>
	 <1325602830.2320.69.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4F032E5E020000780006A36C@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mingo@elte.hu, tglx@linutronix.de,
	Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>, hpa@zytor.com
To: Jan Beulich <JBeulich@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F032E5E020000780006A36C@nat28.tlf.novell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 03 janvier 2012 =C3=A0 15:35 +0000, Jan Beulich a =C3=A9crit :

> And in atomic64_set_cx8 it's the other way around: The comment
> explains why supposedly no LOCK prefix is needed, but that's again
> in conflict with above quoted paragraph from the manual.

BTW atomic64_set() asm() contraints are wrong :

static inline void atomic64_set(atomic64_t *v, long long i)
{
        unsigned high =3D (unsigned)(i >> 32);
        unsigned low =3D (unsigned)i;
        asm volatile(ATOMIC64_ALTERNATIVE(set)
                     : "+b" (low), "+c" (high)
                     : "S" (v)
                     : "eax", "edx", "memory"
                     );
}


ebx/ecx registers are not modified by cmpxchg8b (or the atomic64_set_38=
6
emulation). Only eax/edx can be modified.
