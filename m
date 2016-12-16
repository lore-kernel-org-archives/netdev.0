From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [kernel-hardening] Re: [PATCH v5 1/4] siphash: add
 cryptographically secure PRF
Date: Fri, 16 Dec 2016 22:09:14 +0100
Message-ID: <CAHmME9rzHfKxJkU+3+Xg-Wh48nYkhq7bH55RQVCmTXSTgJ2_VA@mail.gmail.com>
References: <CAGiyFdfmiCMyHvAg=5sGh8KjBBrF0Wb4Qf=JLzJqUAx4yFSS3Q@mail.gmail.com>
 <20161216034618.28276.qmail@ns.sciencehorizons.net> <CAGiyFdd6_LVzUUfFcaqMyub1c2WPvWUzAQDCH+Aza-_t6mvmXg@mail.gmail.com>
 <CAHmME9pjoAsoct1sVDpFFuqaqutv9X7DGJ5OBQXRAS57KFimUA@mail.gmail.com>
 <CALx6S351VFRZmEQphRQy6YtmZYPnOtTN7=XiNrJmhWJGv4HUBg@mail.gmail.com> <1481921067.1054.6.camel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kernel-hardening@lists.openwall.com,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
        George Spelvin <linux@sciencehorizons.net>,
        Andi Kleen <ak@linux.intel.com>,
        David Miller <davem@davemloft.net>,
        David Laight <David.Laight@aculab.com>,
        Eric Biggers <ebiggers3@gmail.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Netdev <netdev@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        "Theodore Ts'o" <tytso@mit.edu>,
        Vegard Nossum <vegard.nossum@gmail.com>,
        "Daniel J . Bernstein" <djb@cr.yp.to>
To: Daniel Micay <danielmicay@gmail.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1481921067.1054.6.camel@gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Daniel,

On Fri, Dec 16, 2016 at 9:44 PM, Daniel Micay <danielmicay@gmail.com> wrote:
> On Fri, 2016-12-16 at 11:47 -0800, Tom Herbert wrote:
>>
>> That's about 3x of jhash speed (7 nsecs). So that might closer
>> to a more palatable replacement for jhash. Do we lose any security
>> advantages with halfsiphash?
>
> Have you tested a lower round SipHash? Probably best to stick with the
> usual construction for non-DoS mitigation, but why not try SipHash 1-3,
> 1-2, etc. for DoS mitigation?
>
> Rust and Swift both went with SipHash 1-3 for hash tables.

Maybe not a bad idea.

SipHash2-4 for MD5 replacement, as we've done so far. This is when we
actually want things to be secure (and fast).

And then HalfSipHash1-3 for certain jhash replacements. This is for
when we're talking only about DoS or sort of just joking about
security, and want things to be very competitive with jhash. (Of
course for 64-bit we'd use SipHash1-3 instead of HalfSipHash for the
speedup.)

I need to think on this a bit more, but preliminarily, I guess this
would be maybe okay...

George, JP - what do you think?

Jason
