From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Re: [PATCH v5 1/4] siphash: add cryptographically
 secure PRF
Date: Fri, 16 Dec 2016 22:15:23 +0100
Message-ID: <1481922923.2204853.821591377.2CD623CB@webmail.messagingengine.com>
References: <CAHmME9pz=syTiLXUsbXFyGdbGK6pxbnU+TVLDkbYiTa-9+sckQ@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: "Jason A. Donenfeld" <Jason@zx2c4.com>,
 kernel-hardening@lists.openwall.com, "Theodore Ts'o" <tytso@mit.edu>,
 George Spelvin <linux@sciencehorizons.net>,
 Andi Kleen <ak@linux.intel.com>, David Miller <davem@davemloft.net>,
 David Laight <David.Laight@aculab.com>,
 "Daniel J . Bernstein" <djb@cr.yp.to>,
 Eric Biggers <ebiggers3@gmail.com>,
 "Jean-Philippe Aumasson" <jeanphilippe.aumasson@gmail.com>,
 Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>,
 Andy Lutomirski <luto@amacapital.net>, Netdev <netdev@vger.kernel.org>,
 Tom Herbert <tom@herbertland.com>,
 Linus Torvalds <torvalds@linux-foundation.org>,
 Vegard Nossum <vegard.nossum@gmail.com>
Return-path: <kernel-hardening-return-5663-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CAHmME9pz=syTiLXUsbXFyGdbGK6pxbnU+TVLDkbYiTa-9+sckQ@mail.gmail.com>
List-Id: netdev.vger.kernel.org

On Fri, Dec 16, 2016, at 22:01, Jason A. Donenfeld wrote:
> Yes, on x86-64. But on i386 chacha20 incurs nearly the same kind of
> slowdown as siphash, so I expect the comparison to be more or less
> equal. There's another thing I really didn't like about your chacha20
> approach which is that it uses the /dev/urandom pool, which means
> various things need to kick in in the background to refill this.
> Additionally, having to refill the buffered chacha output every 32 or
> so longs isn't nice. These things together make for inconsistent and
> hard to understand general operating system performance, because
> get_random_long is called at every process startup for ASLR. So, in
> the end, I believe there's another reason for going with the siphash
> approach: deterministic performance.

*Hust*, so from where do you generate your key for siphash if called
early from ASLR?

Bye,
Hannes
