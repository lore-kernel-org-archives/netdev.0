From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: HalfSipHash Acceptable Usage
Date: Wed, 21 Dec 2016 17:37:12 +0100
Message-ID: <CAHmME9rWWbk7SDxT=RtfNu5TAvMkY6f8ScA=MzQ01e6jrFtR+Q@mail.gmail.com>
References: <CAHmME9oJDOLpPKRpX=N+DY9BuzTueWjTaWzeVtdVMBG7mcrqKA@mail.gmail.com>
 <20161221155540.29529.qmail@ns.sciencehorizons.net>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andi Kleen <ak@linux.intel.com>, David Miller <davem@davemloft.net>,
	David Laight <David.Laight@aculab.com>, "Daniel J . Bernstein" <djb@cr.yp.to>,
	Eric Biggers <ebiggers3@gmail.com>, Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>, kernel-hardening@lists.openwall.com,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	Andy Lutomirski <luto@amacapital.net>, Netdev <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>, Linus Torvalds <torvalds@linux-foundation.org>,
	"Theodore Ts'o" <tytso@mit.edu>, Vegard Nossum <vegard.nossum@gmail.com>
To: George Spelvin <linux@sciencehorizons.net>
Return-path: <kernel-hardening-return-5737-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20161221155540.29529.qmail@ns.sciencehorizons.net>
List-Id: netdev.vger.kernel.org

Hi George,

On Wed, Dec 21, 2016 at 4:55 PM, George Spelvin
<linux@sciencehorizons.net> wrote:
> Actually, DJB just made a very relevant suggestion.
>
> As I've mentioned, the 32-bit performance problems are an x86-specific
> problem.  ARM does very well, and other processors aren't bad at all.
>
> SipHash fits very nicely (and runs very fast) in the MMX registers.
>
> They're 64 bits, and there are 8 of them, so the integer registers can
> be reserved for pointers and loop counters and all that.  And there's
> reference code available.
>
> How much does kernel_fpu_begin()/kernel_fpu_end() cost?

In my experience, these functions are only worth calling when
processing more significant amounts of data. I don't have any
benchmarks, but when I _remove_ all of these calls in a kernel,
accelerated crypto gets noticeably faster (until the system crashes).
We can measure it, though.

By the way, if somehow SipHash becomes acceptably fast on x86, would
you consider HalfSipHash for hash tables to be no longer needed? Or do
you suspect that HalfSipHash will always be faster even on, say,
32-bit ARM.

Jason
