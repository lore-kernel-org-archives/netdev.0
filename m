From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH v5 1/4] siphash: add cryptographically secure PRF
Date: Fri, 16 Dec 2016 15:43:58 -0500
Message-ID: <20161216204358.nlwifgcqnu6pitxs@thunk.org>
References: <CAHmME9pe39s5FWxfKNiRKkHnEO-9v2yLcEQc8rnMC89P6roTmA@mail.gmail.com>
 <20161216201739.24567.qmail@ns.sciencehorizons.net>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason@zx2c4.com, ak@linux.intel.com, davem@davemloft.net,
	David.Laight@aculab.com, djb@cr.yp.to, ebiggers3@gmail.com,
	hannes@stressinduktion.org, jeanphilippe.aumasson@gmail.com,
	kernel-hardening@lists.openwall.com, linux-crypto@vger.kernel.org,
	linux-kernel@vger.kernel.org, luto@amacapital.net,
	netdev@vger.kernel.org, tom@herbertland.com,
	torvalds@linux-foundation.org, vegard.nossum@gmail.com
To: George Spelvin <linux@sciencehorizons.net>
Return-path: <kernel-hardening-return-5655-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
Content-Disposition: inline
In-Reply-To: <20161216201739.24567.qmail@ns.sciencehorizons.net>
List-Id: netdev.vger.kernel.org

On Fri, Dec 16, 2016 at 03:17:39PM -0500, George Spelvin wrote:
> > That's a nice analysis. Might one conclude from that that hsiphash is
> > not useful for our purposes? Or does it still remain useful for
> > network facing code?
> 
> I think for attacks where the threat is a DoS, it's usable.  The point
> is you only have to raise the cost to equal that of a packet flood.
> (Just like in electronic warfare, the best you can possibly do is force
> the enemy to use broadband jamming.)
> 
> Hash collision attacks just aren't that powerful.  The original PoC
> was against an application that implemented a hard limit on hash chain
> length as a DoS defense, which the attack then exploited to turn it into
> a hard DoS.

What should we do with get_random_int() and get_random_long()?  In
some cases it's being used in performance sensitive areas, and where
anti-DoS protection might be enough.  In others, maybe not so much.

If we rekeyed the secret used by get_random_int() and
get_random_long() frequently (say, every minute or every 5 minutes),
would that be sufficient for current and future users of these
interfaces?

						- Ted

P.S.  I'll note that my performance figures when testing changes to
get_random_int() were done on a 32-bit x86; Jason, I'm guessing your
figures were using a 64-bit x86 system?.  I haven't tried 32-bit ARM
or smaller CPU's (e.g., mips, et. al.) that might be more likely to be
used on IoT devices, but I'm worried about those too, of course.
