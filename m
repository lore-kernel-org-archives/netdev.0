From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: HalfSipHash Acceptable Usage
Date: Wed, 21 Dec 2016 15:24:32 +0100
Message-ID: <CAHmME9oJDOLpPKRpX=N+DY9BuzTueWjTaWzeVtdVMBG7mcrqKA@mail.gmail.com>
References: <1482298164.8944.8.camel@edumazet-glaptop3.roam.corp.google.com> <20161221063412.6425.qmail@ns.sciencehorizons.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Andi Kleen <ak@linux.intel.com>,
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161221063412.6425.qmail@ns.sciencehorizons.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi George,

On Wed, Dec 21, 2016 at 7:34 AM, George Spelvin
<linux@sciencehorizons.net> wrote:
> In fact, I have an idea.  Allow me to make the following concrete
> suggestion for using HalfSipHash with 128 bits of key material:
>
> - 64 bits are used as the key.
> - The other 64 bits are used as an IV which is prepended to
>   the message to be hashed.
>
> As a matter of practical implementation, we precompute the effect
> of hashing the IV and store the 128-bit HalfSipHash state, which
> is used just like a 128-bit key.
>
> Because of the way it is constructed, it is obviously no weaker than
> standard HalfSipHash's 64-bit security claim.
>
> I don't know the security of this, and it's almost certainly weaker than
> 128 bits, but I *hope* it's at least a few bits stronger than 64 bits.
> 80 would be enough to dissuade any attacker without a six-figure budget
> (that's per attack, not a one-time capital investment).  96 would be
> ample for our purposes.
>
> What I do know is that it makes a brute-force attack without
> significant cryptanalytic effort impossible.

Depends who's doing the cryptanalytic effort I guess.

Please don't roll your own crypto. It's a dangerous road. Putting
homebrew crypto into the kernel would be an error. Let's stick with
the constructions and security margins that the cryptographers give
us. JP made that fairly clear, I thought.

There are already people working on this problem who undergo peer
review and a career devoted to solving these problems. One result for
small systems that need 128-bit security is Chaskey, which you can go
read about if you're curious.

Jason
