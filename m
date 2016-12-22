From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [kernel-hardening] Re: [PATCH v7 3/6] random: use SipHash in
 place of MD5
Date: Thu, 22 Dec 2016 07:03:29 +0100
Message-ID: <CAHmME9o=yLOLr2w3xYj2up-UW0tXtv=0A5ffiTiVCCHkv6Twxg@mail.gmail.com>
References: <20161216030328.11602-1-Jason@zx2c4.com> <20161221230216.25341-1-Jason@zx2c4.com>
 <20161221230216.25341-4-Jason@zx2c4.com> <CALCETrVttVoZMvCYZcrAqM1c=YQP_nCfdfO1MsrSHjvjTFxH+A@mail.gmail.com>
 <17bd0c70-d2c1-165b-f5b2-252dfca404e8@stressinduktion.org>
 <CAHmME9phg=GuhEUaMxxv_=RexffPDqrOEhmaKffy_ZSt7bfC7g@mail.gmail.com> <20161222054125.lzxhd6ctovm3wk4p@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: kernel-hardening@lists.openwall.com,
        "Theodore Ts'o" <tytso@mit.edu>,
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:55878 "EHLO frisell.zx2c4.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752134AbcLVGDe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 22 Dec 2016 01:03:34 -0500
In-Reply-To: <20161222054125.lzxhd6ctovm3wk4p@thunk.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ted,

On Thu, Dec 22, 2016 at 6:41 AM, Theodore Ts'o <tytso@mit.edu> wrote:
> The bottom line is that I think we're really "pixel peeping" at this
> point --- which is what obsessed digital photographers will do when
> debating the quality of a Canon vs Nikon DSLR by blowing up a photo by
> a thousand times, and then trying to claim that this is visible to the
> human eye.  Or people who obsessing over the frequency response curves
> of TH-X00 headphones with Mahogony vs Purpleheart wood, when it's
> likely that in a blind head-to-head comparison, most people wouldn't
> be able to tell the difference....

This is hilarious, thanks for the laugh. I believe you're right about this...

>
> I think the main argument for using the batched getrandom approach is
> that it, I would argue, simpler than introducing siphash into the
> picture.  On 64-bit platforms it is faster and more consistent, so
> it's basically that versus complexity of having to adding siphash to
> the things that people have to analyze when considering random number
> security on Linux.   But it's a close call either way, I think.

I find this compelling. We'll have one csprng for both
get_random_int/long and for /dev/urandom, and we'll be able to update
that silly warning on the comment of get_random_int/long to read
"gives output of either rdrand quality or of /dev/urandom quality",
which makes it more useful for other things. It introduces less error
prone code, and it lets the RNG analysis be spent on just one RNG, not
two.

So, with your blessing, I'm going to move ahead with implementing a
pretty version of this for v8.

Regards,
Jason
