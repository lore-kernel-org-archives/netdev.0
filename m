From: "Jan Beulich" <JBeulich@suse.com>
Subject: RE: [PATCH] x86: fix and improve cmpxchg_double{,_local}()
Date: Wed, 04 Jan 2012 10:54:22 +0000
Message-ID: <4F043DEE020000780006A575@nat28.tlf.novell.com>
References: <1325611899.2320.111.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <AE90C24D6B3A694183C094C60CF0A2F6D8AF2A@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <mingo@elte.hu>, <tglx@linutronix.de>,
	"Christoph Lameter" <cl@linux.com>, <linux-kernel@vger.kernel.org>,
	"netdev" <netdev@vger.kernel.org>, <hpa@zytor.com>
To: "David Laight" <David.Laight@ACULAB.COM>,
	"Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6D8AF2A@saturn3.aculab.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 >>> On 04.01.12 at 11:36, "David Laight" <David.Laight@ACULAB.COM> wrote:

>> BTW atomic64_set() asm() contraints are wrong :
>> 
>> static inline void atomic64_set(atomic64_t *v, long long i)
>> {
>>         unsigned high = (unsigned)(i >> 32);
>>         unsigned low = (unsigned)i;
>>         asm volatile(ATOMIC64_ALTERNATIVE(set)
>>                      : "+b" (low), "+c" (high)
>>                      : "S" (v)
>>                      : "eax", "edx", "memory"
>>                      );
>> }
>> 
>> 
>> ebx/ecx registers are not modified by cmpxchg8b (or the 
>> atomic64_set_386 emulation). Only eax/edx can be modified.

Same would be true for atomic64_xchg() and the use of "+c" (v)
in subsequent functions (whether unnecessarily strict or too lax
varies).

> Isn't it also possible to constrain the "memory"
> constraint to only apply to '*v' not all of memory?
> I can't remember the syntax off hand though...

Absolutely - "=m" (v->counter) would be the right way to specify
this.

Jan
