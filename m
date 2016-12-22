From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [kernel-hardening] Re: [PATCH v7 3/6] random: use SipHash in
 place of MD5
Date: Thu, 22 Dec 2016 14:50:23 -0500
Message-ID: <20161222195022.t4yp6xtn3qfotq6f@thunk.org>
References: <20161221230216.25341-1-Jason@zx2c4.com>
 <20161221230216.25341-4-Jason@zx2c4.com>
 <CALCETrVttVoZMvCYZcrAqM1c=YQP_nCfdfO1MsrSHjvjTFxH+A@mail.gmail.com>
 <17bd0c70-d2c1-165b-f5b2-252dfca404e8@stressinduktion.org>
 <CAHmME9phg=GuhEUaMxxv_=RexffPDqrOEhmaKffy_ZSt7bfC7g@mail.gmail.com>
 <20161222054125.lzxhd6ctovm3wk4p@thunk.org>
 <1482410840.2472.2.camel@stressinduktion.org>
 <CAHmME9r_zTHo=dxRRK6UrjJ_dKV14yYsZsxCc362z4CPoVkddw@mail.gmail.com>
 <20161222155447.u3ayvw4gmorhswjv@thunk.org>
 <32db19ab-0c19-628c-3475-2ccb8050563a@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>,
        kernel-hardening@lists.openwall.com,
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
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <32db19ab-0c19-628c-3475-2ccb8050563a@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 22, 2016 at 07:08:37PM +0100, Hannes Frederic Sowa wrote:
> I wasn't concerned about performance but more about DoS resilience. I
> wonder how safe half md4 actually is in terms of allowing users to
> generate long hash chains in the filesystem (in terms of length
> extension attacks against half_md4).
> 
> In ext4, is it actually possible that a "disrupter" learns about the
> hashing secret in the way how the inodes are returned during getdents?

They'd have to be a local user, who can execute telldir(3) --- in
which case there are plenty of other denial of service attacks one
could carry out that would be far more devastating.

It might also be an issue if the file system is exposed via NFS, but
again, there are so many other ways an attacker could DoS a NFS server
that I don't think of it as a much of a concern.

Keep in mind that worst someone can do is cause directory inserts to
fail with an ENOSPC, and there are plenty of other ways of doing that
--- such as consuming all of the blocks and inodes in the file system,
for example.

So it's a threat, but not a high priority one as far as I'm concerned.
And if this was a problem in actual practice, users could switch to
the TEA based hash, which should be far harder to attack, and
available today.

					- Ted
