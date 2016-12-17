From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v5 1/4] siphash: add cryptographically secure PRF
Date: Sat, 17 Dec 2016 02:39:50 +0100
Message-ID: <CAHmME9r4YNqNSZ-KXAHtJN_vm+eL1tSoC-6muHaFUN6fWhkO2g@mail.gmail.com>
References: <CAHmME9oEhmqW3320Ch+Rczu_=CxQyUQXCGLnYjDm-CYbWugnSw@mail.gmail.com>
 <20161216234408.30174.qmail@ns.sciencehorizons.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andi Kleen <ak@linux.intel.com>,
        David Miller <davem@davemloft.net>,
        David Laight <David.Laight@aculab.com>,
        "Daniel J . Bernstein" <djb@cr.yp.to>,
        Eric Biggers <ebiggers3@gmail.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
        kernel-hardening@lists.openwall.com,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Netdev <netdev@vger.kernel.org>,
        Tom Herbert <tom@herbertland.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        "Theodore Ts'o" <tytso@mit.edu>,
        Vegard Nossum <vegard.nossum@gmail.com>
To: George Spelvin <linux@sciencehorizons.net>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20161216234408.30174.qmail@ns.sciencehorizons.net>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 17, 2016 at 12:44 AM, George Spelvin
<linux@sciencehorizons.net> wrote:
> Ths advice I'd give now is:
> - Implement
> unsigned long hsiphash(const void *data, size_t len, const unsigned long key[2])
>   .. as SipHash on 64-bit (maybe SipHash-1-3, still being discussed) and
>   HalfSipHash on 32-bit.

I already did this. Check my branch.

> - Document when it may or may not be used carefully.

Good idea. I'll write up some extensive documentation about all of
this, detailing use cases and our various conclusions.

> - #define get_random_int (unsigned)get_random_long

That's a good idea, since ultimately the other just casts in the
return value. I wonder if this could also lead to a similar aliasing
with arch_get_random_int, since I'm pretty sure all rdrand-like
instructions return native word size anyway.

> - Ted, Andy Lutorminski and I will try to figure out a construction of
>   get_random_long() that we all like.

And me, I hope... No need to make this exclusive.

Jason
