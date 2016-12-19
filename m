From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v5 1/4] siphash: add cryptographically secure PRF
Date: Mon, 19 Dec 2016 18:08:47 +0100
Message-ID: <CAHmME9o6CFuQJEp3QJgkh78r5Z2F8NJnpTCCFUiSnAiJxPGCJQ@mail.gmail.com>
References: <20161215203003.31989-1-Jason@zx2c4.com> <20161215203003.31989-2-Jason@zx2c4.com>
 <CAH8yC8nE5CLfbv8gCRCeiNW3JLCAB3062-6pNO8mEXJYcsFUsw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        kernel-hardening@lists.openwall.com,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        David Laight <David.Laight@aculab.com>,
        Ted Tso <tytso@mit.edu>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Eric Biggers <ebiggers3@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        George Spelvin <linux@sciencehorizons.net>,
        Vegard Nossum <vegard.nossum@gmail.com>,
        Andi Kleen <ak@linux.intel.com>,
        David Miller <davem@davemloft.net>,
        Andy Lutomirski <luto@amacapital.net>,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
        "Daniel J . Bernstein" <djb@cr.yp.to>
To: noloader@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAH8yC8nE5CLfbv8gCRCeiNW3JLCAB3062-6pNO8mEXJYcsFUsw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 17, 2016 at 3:55 PM, Jeffrey Walton <noloader@gmail.com> wrote:
> It may be prudent to include the endian reversal in the test to ensure
> big endian machines produce expected results. Some closely related
> testing on an old Apple PowerMac G5 revealed that result needed to be
> reversed before returning it to a caller.

The function [1] returns a u64. Originally I had it returning a
__le64, but that was considered unnecessary by many prior reviewers on
the list. It returns an integer. If you want uniform bytes out of it,
then use the endian conversion function, the same as you would do with
any other type of integer.

Additionally, this function is *not* meant for af_alg or any of the
crypto/* code. It's very unlikely to find a use there.


> Forgive my ignorance... I did not find reading on using the primitive
> in a PRNG. Does anyone know what Aumasson or Bernstein have to say?
> Aumasson's site does not seem to discuss the use case:

He's on this thread so I suppose he can speak up for himself. But in
my conversations with him, the primary take-away was, "seems okay to
me!". But please -- JP - correct me if I've misinterpreted.
