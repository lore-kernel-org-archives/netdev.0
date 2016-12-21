From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v7 3/6] random: use SipHash in place of MD5
Date: Thu, 22 Dec 2016 00:13:34 +0100
Message-ID: <CAHmME9pj01bjb5zcPqM5Mx4hOnhB7a6Ojf1UchhBg0wq=F8GJA@mail.gmail.com>
References: <20161216030328.11602-1-Jason@zx2c4.com> <20161221230216.25341-1-Jason@zx2c4.com>
 <20161221230216.25341-4-Jason@zx2c4.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>
To: Netdev <netdev@vger.kernel.org>, kernel-hardening@lists.openwall.com,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, David Laight <David.Laight@aculab.com>,
	Ted Tso <tytso@mit.edu>, Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>, Linus Torvalds <torvalds@linux-foundation.org>,
	Eric Biggers <ebiggers3@gmail.com>, Tom Herbert <tom@herbertland.com>,
	Andi Kleen <ak@linux.intel.com>, David Miller <davem@davemloft.net>,
	Andy Lutomirski <luto@amacapital.net>,
	Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
Return-path: <kernel-hardening-return-5754-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20161221230216.25341-4-Jason@zx2c4.com>
List-Id: netdev.vger.kernel.org

Hi Ted,

On Thu, Dec 22, 2016 at 12:02 AM, Jason A. Donenfeld <Jason@zx2c4.com> wrote:
> This duplicates the current algorithm for get_random_int/long

I should have mentioned this directly in the commit message, which I
forgot to update: this v7 adds the time-based key rotation, which,
while not strictly necessary for ensuring the security of the RNG,
might help alleviate some concerns, as we talked about. Performance is
quite good on both 32-bit and 64-bit -- better than MD5 in both cases.

If you like this, terrific. If not, I'm happy to take this in whatever
direction you prefer, and implement whatever construction you think
best. There's been a lot of noise on this list about it; we can
continue to discuss more, or you can just tell me whatever you want to
do, and I'll implement it and that'll be the end of it. As you said,
we can always get something decent now and improve it later.

Alternatively, if you've decided in the end you prefer your batched
entropy approach using chacha, I'm happy to implement a polished
version of that here in this patch series (so that we can keep the `rm
lib/md5.c` commit.)

Just let me know how you'd like to proceed.

Thanks,
Jason
