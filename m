From: Jeffrey Walton <noloader@gmail.com>
Subject: Re: Re: [PATCH v5 1/4] siphash: add
 cryptographically secure PRF
Date: Sat, 17 Dec 2016 11:14:47 -0500
Message-ID: <CAH8yC8kYHNo6T9-C3E0vyu7Mz-xGRLzLOifLFYsBMkoK92qmiA@mail.gmail.com>
References: <CAHmME9r4YNqNSZ-KXAHtJN_vm+eL1tSoC-6muHaFUN6fWhkO2g@mail.gmail.com>
 <20161217021503.32767.qmail@ns.sciencehorizons.net> <20161217154152.5oug7mzb4tmfknwv@thunk.org>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: "Theodore Ts'o" <tytso@mit.edu>, kernel-hardening@lists.openwall.com,
	"Jason A. Donenfeld" <Jason@zx2c4.com>, George Spelvin <linux@sciencehorizons.net>, ak@linux.intel.com,
	davem@davemloft.net, David Laight <David.Laight@aculab.com>,
	"D. J. Bernstein" <djb@cr.yp.to>, Eric Biggers <ebiggers3@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>, linux-crypto@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, luto@amacapital.net,
	Netdev <netdev@vger.kernel.org>, Tom Herbert <tom@herbertland.com>,
	Linus Torvalds <torvalds@linux-foundation.org>, Vegard Nossum <vegard.nossum@gmail.com>
Return-path: <kernel-hardening-return-5693-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20161217154152.5oug7mzb4tmfknwv@thunk.org>
List-Id: netdev.vger.kernel.org

> As far as half-siphash is concerned, it occurs to me that the main
> problem will be those users who need to guarantee that output can't be
> guessed over a long period of time.  For example, if you have a
> long-running process, then the output needs to remain unguessable over
> potentially months or years, or else you might be weakening the ASLR
> protections.  If on the other hand, the hash table or the process will
> be going away in a matter of seconds or minutes, the requirements with
> respect to cryptographic strength go down significantly.

Perhaps SipHash-4-8 should be used instead of SipHash-2-4. I believe
SipHash-4-8 is recommended for the security conscious who want to be
more conservative in their security estimates.

SipHash-4-8 does not add much more processing. If you are clocking
SipHash-2-4 at 2.0 or 2.5 cpb, then SipHash-4-8 will run at 3.0 to
4.0. Both are well below MD5 times. (At least with the data sets I've
tested).

> Now, maybe this doesn't matter that much if we can guarantee (or make
> assumptions) that the attacker doesn't have unlimited access the
> output stream of get_random_{long,int}(), or if it's being used in an
> anti-DOS use case where it ultimately only needs to be harder than
> alternate ways of attacking the system.
>
> Rekeying every five minutes doesn't necessarily help the with respect
> to ASLR, but it might reduce the amount of the output stream that
> would be available to the attacker in order to be able to attack the
> get_random_{long,int}() generator, and it also reduces the value of
> doing that attack to only compromising the ASLR for those processes
> started within that five minute window.

Forgive my ignorance... I did not find reading on using the primitive
in a PRNG. Does anyone know what Aumasson or Bernstein have to say?
Aumasson's site does not seem to discuss the use case:
https://www.google.com/search?q=siphash+rng+site%3A131002.net. (And
their paper only mentions random-number once in a different context).

Making the leap from internal hash tables and short-lived network
packets to the rng case may leave something to be desired, especially
if the bits get used in unanticipated ways, like creating long term
private keys.

Jeff
