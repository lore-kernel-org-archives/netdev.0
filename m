From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: Re: [PATCH v7 3/6] random: use SipHash in
 place of MD5
Date: Thu, 22 Dec 2016 10:54:47 -0500
Message-ID: <20161222155447.u3ayvw4gmorhswjv@thunk.org>
References: <20161216030328.11602-1-Jason@zx2c4.com>
 <20161221230216.25341-1-Jason@zx2c4.com>
 <20161221230216.25341-4-Jason@zx2c4.com>
 <CALCETrVttVoZMvCYZcrAqM1c=YQP_nCfdfO1MsrSHjvjTFxH+A@mail.gmail.com>
 <17bd0c70-d2c1-165b-f5b2-252dfca404e8@stressinduktion.org>
 <CAHmME9phg=GuhEUaMxxv_=RexffPDqrOEhmaKffy_ZSt7bfC7g@mail.gmail.com>
 <20161222054125.lzxhd6ctovm3wk4p@thunk.org>
 <1482410840.2472.2.camel@stressinduktion.org>
 <CAHmME9r_zTHo=dxRRK6UrjJ_dKV14yYsZsxCc362z4CPoVkddw@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel-hardening@lists.openwall.com,
	Andy Lutomirski <luto@amacapital.net>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	David Laight <David.Laight@aculab.com>,
	Eric Dumazet <edumazet@google.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Eric Biggers <ebiggers3@gmail.com>,
	Tom Herbert <tom@herbertland.com>, Andi Kleen <ak@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <kernel-hardening-return-5785-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
Content-Disposition: inline
In-Reply-To: <CAHmME9r_zTHo=dxRRK6UrjJ_dKV14yYsZsxCc362z4CPoVkddw@mail.gmail.com>
List-Id: netdev.vger.kernel.org

On Thu, Dec 22, 2016 at 02:10:33PM +0100, Jason A. Donenfeld wrote:
> On Thu, Dec 22, 2016 at 1:47 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> > following up on what appears to be a random subject: ;)
> >
> > IIRC, ext4 code by default still uses half_md4 for hashing of filenames
> > in the htree. siphash seems to fit this use case pretty good.
> 
> I saw this too. I'll try to address it in v8 of this series.

This is a separate issue, and this series is getting a bit too
complex.  So I'd suggest pushing this off to a separate change.

Changing the htree hash algorithm is an on-disk format change, and so
we couldn't roll it out until e2fsprogs gets updated and rolled out
pretty broadley.  In fact George sent me patches to add siphash as a
hash algorithm for htree a while back (for both the kernel and
e2fsprogs), but I never got around to testing and applying them,
mainly because while it's technically faster, I had other higher
priority issues to work on --- and see previous comments regarding
pixel peeping.  Improving the hash algorithm by tens or even hundreds
of nanoseconds isn't really going to matter since we only do a htree
lookup on a file creation or cold cache lookup, and the SSD or HDD I/O
times will dominate.  And from the power perspective, saving
microwatts of CPU power isn't going to matter if you're going to be
spinning up the storage device....

						- Ted
