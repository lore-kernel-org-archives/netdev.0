From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: Re: [PATCH v7 3/6] random: use SipHash in
 place of MD5
Date: Thu, 22 Dec 2016 17:16:47 +0100
Message-ID: <CAHmME9r3zCE6zLsL9Jrp3a2D3mpH6oYEnz3BBerAGZXyJpr2mQ@mail.gmail.com>
References: <20161216030328.11602-1-Jason@zx2c4.com> <20161221230216.25341-1-Jason@zx2c4.com>
 <20161221230216.25341-4-Jason@zx2c4.com> <CALCETrVttVoZMvCYZcrAqM1c=YQP_nCfdfO1MsrSHjvjTFxH+A@mail.gmail.com>
 <17bd0c70-d2c1-165b-f5b2-252dfca404e8@stressinduktion.org>
 <CAHmME9phg=GuhEUaMxxv_=RexffPDqrOEhmaKffy_ZSt7bfC7g@mail.gmail.com>
 <20161222054125.lzxhd6ctovm3wk4p@thunk.org> <CAHmME9o=yLOLr2w3xYj2up-UW0tXtv=0A5ffiTiVCCHkv6Twxg@mail.gmail.com>
 <20161222155853.beqowf2qfg7igf23@thunk.org>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: "Theodore Ts'o" <tytso@mit.edu>, "Jason A. Donenfeld" <Jason@zx2c4.com>, kernel-hardening@lists.openwall.com,
	Hannes Frederic Sowa <hannes@stressinduktion.org>, Andy Lutomirski <luto@amacapital.net>,
	Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, David Laight <David.Laight@aculab.com>,
	Eric Dumazet <edumazet@google.com>, Linus Torvalds <torvalds@linux-foundation.org>,
	Eric Biggers <ebiggers3@gmail.com>, Tom Herbert <tom@herbertland.com>,
	Andi Kleen <ak@linux.intel.com>, "David S. Miller" <davem@davemloft.net>,
	Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
Return-path: <kernel-hardening-return-5789-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20161222155853.beqowf2qfg7igf23@thunk.org>
List-Id: netdev.vger.kernel.org

Hi Ted,

On Thu, Dec 22, 2016 at 4:58 PM, Theodore Ts'o <tytso@mit.edu> wrote:
> Can we do this as a separate series, please?  At this point, it's a
> completely separate change from a logical perspective, and we can take
> in the change through the random.git tree.
>
> Changes that touch files that are normally changed in several
> different git trees leads to the potential for merge conflicts during
> the linux-next integration and merge window processes.  Which is why
> it's generally best to try to isolate changes as much as possible.

Sure, I can separate things out.

Could you offer a bit of advice on how to manage dependencies between
patchsets during merge windows? I'm a bit new to the process.

Specifically, we how have 4 parts:
1. add siphash, and use it for some networking code. to: david miller's net-next
2. convert char/random to use siphash. to: ted ts'o's random-next
3. move lib/md5.c to static function in crypto/md5.c, remove entry
inside of linux/cryptohash.h. to: ??'s ??-next
4. move lib/halfmd4.c to static function in fs/ext/hash.c, remove
entry inside of linux/cryptohash.c. to: td ts'o's ext-next

Problem: 2 depends on 1, 3 depends on 1 & 2. But this can be
simplified into 3 parts:

1. add siphash, and use it for some networking code. to: david miller's net-next
2. convert char/random to use siphash, move lib/md5.c to static
function in crypto/md5.c, remove entry inside of linux/cryptohash.h.
to: ted ts'o's random-next
3. move lib/halfmd4.c to static function in fs/ext/hash.c, remove
entry inside of linux/cryptohash.c. to: td ts'o's ext-next

Problem: 2 depends on 1. Is that okay with you?

Also, would you like me to merge (3) and (2) of the second list into
one series for you?

Jason
