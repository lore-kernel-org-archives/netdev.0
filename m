From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [kernel-hardening] Re: [PATCH v7 3/6] random: use SipHash in
 place of MD5
Date: Thu, 22 Dec 2016 17:36:47 +0100
Message-ID: <CAHmME9o6Qt5aLrP68p-6yPrLz9+DP_kictsXa5GbKz0Bfa3o7Q@mail.gmail.com>
References: <20161216030328.11602-1-Jason@zx2c4.com> <20161221230216.25341-1-Jason@zx2c4.com>
 <20161221230216.25341-4-Jason@zx2c4.com> <CALCETrVttVoZMvCYZcrAqM1c=YQP_nCfdfO1MsrSHjvjTFxH+A@mail.gmail.com>
 <17bd0c70-d2c1-165b-f5b2-252dfca404e8@stressinduktion.org>
 <CAHmME9phg=GuhEUaMxxv_=RexffPDqrOEhmaKffy_ZSt7bfC7g@mail.gmail.com>
 <20161222054125.lzxhd6ctovm3wk4p@thunk.org> <CAHmME9o=yLOLr2w3xYj2up-UW0tXtv=0A5ffiTiVCCHkv6Twxg@mail.gmail.com>
 <20161222155853.beqowf2qfg7igf23@thunk.org> <CAHmME9r3zCE6zLsL9Jrp3a2D3mpH6oYEnz3BBerAGZXyJpr2mQ@mail.gmail.com>
 <20161222163041.xb2ysx4uswpaqfev@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: kernel-hardening@lists.openwall.com,
        "Theodore Ts'o" <tytso@mit.edu>,
        "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        David Laight <David.Laight@aculab.com>,
        Eric Dumazet <edumazet@google.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Eric Biggers <ebiggers3@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Andi Kleen <ak@linux.intel.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20161222163041.xb2ysx4uswpaqfev@thunk.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 22, 2016 at 5:30 PM, Theodore Ts'o <tytso@mit.edu> wrote:
> I'd do this first, as one set.  Adding a new file to crypto is
> unlikely to cause merge conflicts.

Ack.

>
>> 2. convert char/random to use siphash. to: ted ts'o's random-next
>
> I'm confused, I thought you had agreed to the batched chacha20
> approach?

Sorry, I meant to write this. Long day, little sleep. Yes, of course.
Batched entropy.

>> 3. move lib/md5.c to static function in crypto/md5.c, remove entry
>> inside of linux/cryptohash.h. to: ??'s ??-next
>
> This is cleanup, so it doesn't matter that much when it happens.  md5
> changes to crypto is also unlikely to cause conflicts, so we could do
> this at the same time as (2), if Herbert (the crypto maintainer) agrees.

Alright, sure.

>
>> 4. move lib/halfmd4.c to static function in fs/ext/hash.c, remove
>> entry inside of linux/cryptohash.c. to: td ts'o's ext-next
>
> This is definitely separate.

Okay, I'll submit it to you separately.

> One more thing.  Can you add some test cases to lib/siphash.h?
> Triggered off of a CONFIG_SIPHASH_REGRESSION_TEST config flag, with
> some test inputs and known outputs?  I'm going to need to add a
> version of siphash to e2fsprogs, and I want to make sure the userspace
> version is implementing the same algorithm as the kernel siphash.

I've already written these. They're behind TEST_HASH. They currently
test every single line of code of all implementations of siphash. I
spent a long time on these. The test vectors themselves were taken
from the SipHash creators' reference publication. Check out
lib/test_siphash.c in my tree.

Jason

On Thu, Dec 22, 2016 at 5:30 PM, Theodore Ts'o <tytso@mit.edu> wrote:
> On Thu, Dec 22, 2016 at 05:16:47PM +0100, Jason A. Donenfeld wrote:
>> Could you offer a bit of advice on how to manage dependencies between
>> patchsets during merge windows? I'm a bit new to the process.
>>
>> Specifically, we how have 4 parts:
>> 1. add siphash, and use it for some networking code. to: david miller's net-next
>
> I'd do this first, as one set.  Adding a new file to crypto is
> unlikely to cause merge conflicts.
>
>> 2. convert char/random to use siphash. to: ted ts'o's random-next
>
> I'm confused, I thought you had agreed to the batched chacha20
> approach?
>
>> 3. move lib/md5.c to static function in crypto/md5.c, remove entry
>> inside of linux/cryptohash.h. to: ??'s ??-next
>
> This is cleanup, so it doesn't matter that much when it happens.  md5
> changes to crypto is also unlikely to cause conflicts, so we could do
> this at the same time as (2), if Herbert (the crypto maintainer) agrees.
>
>> 4. move lib/halfmd4.c to static function in fs/ext/hash.c, remove
>> entry inside of linux/cryptohash.c. to: td ts'o's ext-next
>
> This is definitely separate.
>
> One more thing.  Can you add some test cases to lib/siphash.h?
> Triggered off of a CONFIG_SIPHASH_REGRESSION_TEST config flag, with
> some test inputs and known outputs?  I'm going to need to add a
> version of siphash to e2fsprogs, and I want to make sure the userspace
> version is implementing the same algorithm as the kernel siphash.
>
>                                               - Ted



-- 
Jason A. Donenfeld
Deep Space Explorer
fr: +33 6 51 90 82 66
us: +1 513 476 1200
www.jasondonenfeld.com
www.zx2c4.com
zx2c4.com/keys/AB9942E6D4A4CFC3412620A749FC7012A5DE03AE.asc
