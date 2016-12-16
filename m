From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v5 3/4] secure_seq: use SipHash in place of MD5
Date: Fri, 16 Dec 2016 16:57:38 +0100
Message-ID: <CAHmME9quRDe2FZgV4oAnJ_Cj_GDJo5pUAmQkdpeJe+7_TNMuiA@mail.gmail.com>
References: <20161215203003.31989-1-Jason@zx2c4.com> <20161215203003.31989-4-Jason@zx2c4.com>
 <063D6719AE5E284EB5DD2968C1650D6DB0240E66@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        LKML <linux-kernel@vger.kernel.org>,
        "linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>,
        Ted Tso <tytso@mit.edu>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Eric Biggers <ebiggers3@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        George Spelvin <linux@sciencehorizons.net>,
        Vegard Nossum <vegard.nossum@gmail.com>,
        "ak@linux.intel.com" <ak@linux.intel.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "luto@amacapital.net" <luto@amacapital.net>
To: David Laight <David.Laight@aculab.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB0240E66@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On Fri, Dec 16, 2016 at 10:59 AM, David Laight <David.Laight@aculab.com> wrote:
> You are still putting over-aligned data on stack.
> You only need to align it to the alignment of u64 (not the size of u64).
> If an on-stack item has a stronger alignment requirement than the stack
> the gcc has to generate two stack frames for the function.

Yesterday, folks were saying that sometimes 32-bit platforms need
8-byte alignment for certain 64-bit operations, so I shouldn't fall
back to 4-byte alignment there. But actually, looking at this more
closely, I can just make SIPHASH_ALIGNMENT == __alignof__(u64), which
will take care of all possible concerns, since gcc knows best which
platforms need what alignment. Thanks for making this clear to me with
"the alignment of u64 (not the size of u64)".

> Oh - and wait a bit longer between revisions.

Okay. We can be turtles.

Jason
