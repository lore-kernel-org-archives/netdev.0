From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH v5 1/4] siphash: add cryptographically secure PRF
Date: Fri, 16 Dec 2016 14:15:57 -0800
Message-ID: <CALCETrVXgxy9fvznawtqf+NKda8G9-WpDuD=4_jMmOrx-E59Bw@mail.gmail.com>
References: <20161216204358.nlwifgcqnu6pitxs@thunk.org> <20161216221352.26899.qmail@ns.sciencehorizons.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Ted Ts'o" <tytso@mit.edu>, Andi Kleen <ak@linux.intel.com>,
        "David S. Miller" <davem@davemloft.net>,
        David Laight <David.Laight@aculab.com>,
        "D. J. Bernstein" <djb@cr.yp.to>,
        Eric Biggers <ebiggers3@gmail.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Tom Herbert <tom@herbertland.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Vegard Nossum <vegard.nossum@gmail.com>
To: George Spelvin <linux@sciencehorizons.net>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20161216221352.26899.qmail@ns.sciencehorizons.net>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 16, 2016 at 2:13 PM, George Spelvin
<linux@sciencehorizons.net> wrote:
>> What should we do with get_random_int() and get_random_long()?  In
>> some cases it's being used in performance sensitive areas, and where
>> anti-DoS protection might be enough.  In others, maybe not so much.
>
> This is tricky.  The entire get_random_int() structure is an abuse of
> the hash function and will need to be thoroughly rethought to convert
> it to SipHash.  Remember, SipHash's security goals are very different
> from MD5, so there's no obvious way to do the conversion.
>
> (It's *documented* as "not cryptographically secure", but we know
> where that goes.)
>
>> If we rekeyed the secret used by get_random_int() and
>> get_random_long() frequently (say, every minute or every 5 minutes),
>> would that be sufficient for current and future users of these
>> interfaces?
>
> Remembering that on "real" machines it's full SipHash, then I'd say that
> 64-bit security + rekeying seems reasonable.
>
> The question is, the idea has recently been floated to make hsiphash =
> SipHash-1-3 on 64-bit machines.  Is *that* okay?
>
>
> The annoying thing about the currently proposed patch is that the *only*
> chaining is the returned value.  What I'd *like* to do is the same
> pattern as we do with md5, and remember v[0..3] between invocations.
> But there's no partial SipHash primitive; we only get one word back.
>
> Even
>         *chaining += ret = siphash_3u64(...)
>
> would be an improvement.

This is almost exactly what I suggested in my email on the other
thread from a few seconds ago :)

--Andy
