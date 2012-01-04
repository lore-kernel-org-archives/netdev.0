From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] x86: fix and improve cmpxchg_double{,_local}()
Date: Wed, 4 Jan 2012 10:36:34 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6D8AF2A@saturn3.aculab.com>
References: <1325611899.2320.111.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <mingo@elte.hu>, <tglx@linutronix.de>,
	"Christoph Lameter" <cl@linux.com>, <linux-kernel@vger.kernel.org>,
	"netdev" <netdev@vger.kernel.org>, <hpa@zytor.com>
To: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"Jan Beulich" <JBeulich@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <1325611899.2320.111.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 
> BTW atomic64_set() asm() contraints are wrong :
> 
> static inline void atomic64_set(atomic64_t *v, long long i)
> {
>         unsigned high = (unsigned)(i >> 32);
>         unsigned low = (unsigned)i;
>         asm volatile(ATOMIC64_ALTERNATIVE(set)
>                      : "+b" (low), "+c" (high)
>                      : "S" (v)
>                      : "eax", "edx", "memory"
>                      );
> }
> 
> 
> ebx/ecx registers are not modified by cmpxchg8b (or the 
> atomic64_set_386 emulation). Only eax/edx can be modified.

Isn't it also possible to constrain the "memory"
constraint to only apply to '*v' not all of memory?
I can't remember the syntax off hand though...

	David
