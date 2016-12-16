From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v5 1/4] siphash: add cryptographically secure PRF
Date: Fri, 16 Dec 2016 16:51:35 +0100
Message-ID: <CAHmME9rxCYfwyF6EADWqpAEt+yqCPgCLUVH0FPdAy7r-oPnrRg@mail.gmail.com>
References: <CAGiyFdfmiCMyHvAg=5sGh8KjBBrF0Wb4Qf=JLzJqUAx4yFSS3Q@mail.gmail.com>
 <20161216034618.28276.qmail@ns.sciencehorizons.net> <CAGiyFdd6_LVzUUfFcaqMyub1c2WPvWUzAQDCH+Aza-_t6mvmXg@mail.gmail.com>
 <CAHmME9pjoAsoct1sVDpFFuqaqutv9X7DGJ5OBQXRAS57KFimUA@mail.gmail.com> <CAGiyFddB_HT3H2yhYQ5rprYZ487rJ4iCaH9uPJQD57hiPbn9ng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: George Spelvin <linux@sciencehorizons.net>,
        Andi Kleen <ak@linux.intel.com>,
        David Miller <davem@davemloft.net>,
        David Laight <David.Laight@aculab.com>,
        Eric Biggers <ebiggers3@gmail.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        kernel-hardening@lists.openwall.com,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Netdev <netdev@vger.kernel.org>,
        Tom Herbert <tom@herbertland.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        "Theodore Ts'o" <tytso@mit.edu>, vegard.nossum@gmail.com,
        "Daniel J . Bernstein" <djb@cr.yp.to>
To: Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <CAGiyFddB_HT3H2yhYQ5rprYZ487rJ4iCaH9uPJQD57hiPbn9ng@mail.gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi JP & George,

My function names:
- SipHash -> siphash
- HalfSipHash -> hsiphash

It appears that hsiphash can produce either 32-bit output or 64-bit
output, with the output length parameter as part of the hash algorithm
in there. When I code this for my kernel patchset, I very likely will
only implement one output length size. Right now I'm leaning toward
32-bit. Questions:

- Is this a reasonable choice?
- When hsiphash is desired due to its faster speed, are there any
circumstances in which producing a 64-bit output would actually be
useful? Namely, are there any hashtables that could benefit from a
64-bit functions?
- Are there reasons why hsiphash with 64-bit output would be
reasonable? Or will we be fine sticking with 32-bit output only?

With both hsiphash and siphash, the division of usage will probably become:
- Use 64-bit output 128-bit key siphash for keyed RNG-like things,
such as syncookies and sequence numbers
- Use 64-bit output 128-bit key siphash for hashtables that must
absolutely be secure to an extremely high bandwidth attacker, such as
userspace directly DoSing a kernel hashtable
- Use 32-bit output 64-bit key hsiphash for quick hashtable functions
that still must be secure but do not require as large of a security
margin

Sound good?

Jason
