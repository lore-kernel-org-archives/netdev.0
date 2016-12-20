From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: HalfSipHash Acceptable Usage
Date: Tue, 20 Dec 2016 15:55:45 -0800
Message-ID: <1482278145.1521.46.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAHmME9rPmH=wP_eHYopt8ZPG9TSN7bos3fGOuqKL2HjQW-2SWA@mail.gmail.com>
         <20161220213636.tiqj2o4uupasr4aj@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Biggers <ebiggers3@gmail.com>,
        "Daniel J . Bernstein" <djb@cr.yp.to>,
        David Laight <David.Laight@aculab.com>,
        David Miller <davem@davemloft.net>,
        Andi Kleen <ak@linux.intel.com>,
        George Spelvin <linux@sciencehorizons.net>,
        kernel-hardening@lists.openwall.com,
        Andy Lutomirski <luto@amacapital.net>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        Tom Herbert <tom@herbertland.com>,
        Vegard Nossum <vegard.nossum@gmail.com>,
        Netdev <netdev@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>
To: Theodore Ts'o <tytso@mit.edu>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20161220213636.tiqj2o4uupasr4aj@thunk.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-12-20 at 16:36 -0500, Theodore Ts'o wrote:
> On Mon, Dec 19, 2016 at 06:32:44PM +0100, Jason A. Donenfeld wrote:
> > 1) Anything that requires actual long-term security will use
> > SipHash2-4, with the 64-bit output and the 128-bit key. This includes
> > things like TCP sequence numbers. This seems pretty uncontroversial to
> > me. Seem okay to you?
> 
> Um, why do TCP sequence numbers need long-term security?  So long as
> you rekey every 5 minutes or so, TCP sequence numbers don't need any
> more security than that, since even if you break the key used to
> generate initial sequence numbers seven a minute or two later, any
> pending TCP connections will have timed out long before.
> 
> See the security analysis done in RFC 6528[1], where among other
> things, it points out why MD5 is acceptable with periodic rekeying,
> although there is the concern that this could break certain hueristics
> used when establishing new connections during the TIME-WAIT state.
> 
> [1] https://tools.ietf.org/html/rfc6528


We do not use rekeying for TCP ISN, not anymore after commit
6e5714eaf77d79ae1 (where we switched from MD4 to MD5 )

It might hurt some common cases and I do not believe it is mandated by a
current (ie not obsolete) RFC.

Our clock has a 64 ns resolution and 274 second period (commit
9b42c336d0641) (compared to 4 usec one in RFC 6528)

I do not see why SipHash, if faster than MD5 and more secure, would be a
problem.

Same for syncookies.

BTW, we probably should add a ratelimit on SYNACK retransmits,
because it seems that attackers understood linux kernels resist to
synfloods, and they (the bad guys) use reflection attacks.
