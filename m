From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v2 1/4] siphash: add cryptographically secure hashtable function
Date: Wed, 14 Dec 2016 20:47:10 +0100
Message-ID: <CAHmME9qYgAgQe3UyqWAOrHdOUaR2aO_hxoCMrof-sGVRr6T-Jw@mail.gmail.com>
References: <20161214035927.30004-1-Jason@zx2c4.com> <516c5633-14c2-ee18-90e4-84d73870ba2c@stressinduktion.org>
 <CAHmME9qA6qKdp+qoih2Je4fxU+4E6=Gp7CVfhYU7VbOr6HJ=0Q@mail.gmail.com> <9fea41e0-fd55-7328-e2f4-73eb2e7f7a98@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        kernel-hardening@lists.openwall.com,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
        "Daniel J . Bernstein" <djb@cr.yp.to>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Eric Biggers <ebiggers3@gmail.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <9fea41e0-fd55-7328-e2f4-73eb2e7f7a98@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Hannes,

On Wed, Dec 14, 2016 at 4:09 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> Yes, numbers would be very usable here. I am mostly concerned about
> small plastic router cases. E.g. assume you double packet processing
> time with a change of the hashing function at what point is the actual
> packet processing more of an attack vector than the hashtable?

I agree. Looks like Tom did some very quick benchmarks. I'll do some
more precise benchmarks myself when we graduate from looking at md5
replacement (the easy case) to looking at jhash replacement (the
harder case).

>> With that said, siphash is here to replace uses of jhash where
>> hashtable poisoning vulnerabilities make it necessary. Where there's
>> no significant security improvement, if there's no speed improvement
>> either, then of course nothing's going to change.
>
> It still changes currently well working source. ;-)

I mean if siphash doesn't make things better in someway, we'll just
continue using jhash, so no source change or anything. In other words:
evolutionary conservative approach rather than hasty "replace 'em
all!" tomfoolery.

> MD5 is considered broken because its collision resistance is broken?
> SipHash doesn't even claim to have collision resistance (which we don't
> need here)?

Not just that, but it's not immediately clear to me that using MD5 as
a PRF the way it is now with md5_transform is even a straightforwardly
good idea.

> But I agree, certainly it could be a nice speed-up!

The benchmarks for the secure sequence number generation and the rng
are indeed really promising.

> I think you mean non-linearity.

Yea of course, editing typo, sorry.

> In general I am in favor to switch to siphash, but it would be nice to
> see some benchmarks with the specific kernel implementation also on some
> smaller 32 bit CPUs and especially without using any SIMD instructions
> (which might have been used in paper comparison).

Sure, agreed. Each proposed jhash replacement will need to be
benchmarked on little MIPS machines and x86 monsters alike, with
patches indicating PPS before and after.

Jason
