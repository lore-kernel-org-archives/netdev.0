From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [kernel-hardening] Re: HalfSipHash Acceptable Usage
Date: Thu, 22 Dec 2016 05:40:09 +0100
Message-ID: <CAHmME9oK8EkL7XGT-HwjUjyDW4aw9iDMe7xZE08FbheO2+FKrA@mail.gmail.com>
References: <CAHmME9pww5Q0Wy9MtkO7PAx2Tstfp=6Og3qZLZ=Rh8NaFo0Gog@mail.gmail.com>
 <20161222035549.10827.qmail@ns.sciencehorizons.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andi Kleen <ak@linux.intel.com>,
        David Miller <davem@davemloft.net>,
        David Laight <David.Laight@aculab.com>,
        "Daniel J . Bernstein" <djb@cr.yp.to>,
        Eric Biggers <ebiggers3@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161222035549.10827.qmail@ns.sciencehorizons.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi George,

On Thu, Dec 22, 2016 at 4:55 AM, George Spelvin
<linux@sciencehorizons.net> wrote:
> Do we have to go through this?  No, the benchmark was *not* bogus.
> Then I replaced the kernel #includes with the necessary typedefs
> and #defines to make it compile in user-space.
> * I didn't iterate 100K times, I timed the functions *once*.
> * I saved the times in a buffer and printed them all at the end
>   so printf() wouldn't pollute the caches.
> * Before every even-numbered iteration, I flushed the I-cache
>   of everything from _init to _fini (i.e. all the non-library code).
>   This cold-cache case is what is going to happen in the kernel.

Wow! Great. Thanks for the pointers on the right way to do this. Very
helpful, and enlightening results indeed. Think you could send me the
whole .c of what you finally came up with? I'd like to run this on
some other architectures; I've got a few odd boxes laying around here.

> The P4 results were:
> SipHash actually wins slightly in the cold-cache case, because
> it iterates more.  In the hot-cache case, it loses
> Core 2 duo:
> Pretty much a tie, honestly.
> Ivy Bridge:
> Modern processors *hate* cold caches.  But notice how md5 is *faster*
> than SipHash on hot-cache IPv6.
> Ivy Bridge, -m64:
> Of course, when you compile -m64, SipHash is unbeatable.

Okay, so I think these results are consistent with some of the
assessments from before -- that SipHash is really just fine as a
replacement for MD5. Not great on older 32-bit x86, but not too
horrible, and the performance improvements on every other architecture
and the security improvements everywhere are a net good.

> Here's the modified benchmark() code.  The entire package is
> a bit voluminous for the mailing list, but anyone is welcome to it.

Please do send! I'm sure I'll learn from reading it. Thanks again for
doing the hardwork of putting something proper together.

Thanks,
Jason
