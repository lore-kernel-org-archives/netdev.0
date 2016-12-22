From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v7 1/6] siphash: add cryptographically secure PRF
Date: Wed, 21 Dec 2016 17:40:26 -0800
Message-ID: <20161221174026.1b25fd80@xeon-e3>
References: <20161216030328.11602-1-Jason@zx2c4.com>
	<20161221230216.25341-1-Jason@zx2c4.com>
	<20161221230216.25341-2-Jason@zx2c4.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, kernel-hardening@lists.openwall.com,
 LKML <linux-kernel@vger.kernel.org>, linux-crypto@vger.kernel.org, David
 Laight <David.Laight@aculab.com>, Ted Tso <tytso@mit.edu>, Hannes Frederic
 Sowa <hannes@stressinduktion.org>, edumazet@google.com, Linus Torvalds
 <torvalds@linux-foundation.org>, Eric Biggers <ebiggers3@gmail.com>, Tom
 Herbert <tom@herbertland.com>, ak@linux.intel.com, davem@davemloft.net,
 luto@amacapital.net, Jean-Philippe Aumasson
 <jeanphilippe.aumasson@gmail.com>, Eric Dumazet <eric.dumazet@gmail.com>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <kernel-hardening-return-5759-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20161221230216.25341-2-Jason@zx2c4.com>
List-Id: netdev.vger.kernel.org

On Thu, 22 Dec 2016 00:02:11 +0100
"Jason A. Donenfeld" <Jason@zx2c4.com> wrote:

> SipHash is a 64-bit keyed hash function that is actually a
> cryptographically secure PRF, like HMAC. Except SipHash is super fast,
> and is meant to be used as a hashtable keyed lookup function, or as a
> general PRF for short input use cases, such as sequence numbers or RNG
> chaining.
> 
> For the first usage:
> 
> There are a variety of attacks known as "hashtable poisoning" in which an
> attacker forms some data such that the hash of that data will be the
> same, and then preceeds to fill up all entries of a hashbucket. This is
> a realistic and well-known denial-of-service vector. Currently
> hashtables use jhash, which is fast but not secure, and some kind of
> rotating key scheme (or none at all, which isn't good). SipHash is meant
> as a replacement for jhash in these cases.
> 
> There are a modicum of places in the kernel that are vulnerable to
> hashtable poisoning attacks, either via userspace vectors or network
> vectors, and there's not a reliable mechanism inside the kernel at the
> moment to fix it. The first step toward fixing these issues is actually
> getting a secure primitive into the kernel for developers to use. Then
> we can, bit by bit, port things over to it as deemed appropriate.
> 
> While SipHash is extremely fast for a cryptographically secure function,
> it is likely a bit slower than the insecure jhash, and so replacements
> will be evaluated on a case-by-case basis based on whether or not the
> difference in speed is negligible and whether or not the current jhash usage
> poses a real security risk.
> 
> For the second usage:
> 
> A few places in the kernel are using MD5 or SHA1 for creating secure
> sequence numbers, syn cookies, port numbers, or fast random numbers.
> SipHash is a faster and more fitting, and more secure replacement for MD5
> in those situations. Replacing MD5 and SHA1 with SipHash for these uses is
> obvious and straight-forward, and so is submitted along with this patch
> series. There shouldn't be much of a debate over its efficacy.
> 
> Dozens of languages are already using this internally for their hash
> tables and PRFs. Some of the BSDs already use this in their kernels.
> SipHash is a widely known high-speed solution to a widely known set of
> problems, and it's time we catch-up.
> 
> Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
> Cc: Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Eric Biggers <ebiggers3@gmail.com>
> Cc: David Laight <David.Laight@aculab.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>

The networking tree (net-next) which is where you are submitting to is technically
closed right now.
