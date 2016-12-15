From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH v5 0/4] The SipHash Patchset
Date: Thu, 15 Dec 2016 21:29:59 +0100
Message-ID: <20161215203003.31989-1-Jason@zx2c4.com>
Reply-To: kernel-hardening@lists.openwall.com
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>
To: Netdev <netdev@vger.kernel.org>,
	kernel-hardening@lists.openwall.com,
	LKML <linux-kernel@vger.kernel.org>,
	linux-crypto@vger.kernel.org,
	David Laight <David.Laight@aculab.com>,
	Ted Tso <tytso@mit.edu>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Eric Biggers <ebiggers3@gmail.com>,
	Tom Herbert <tom@herbertland.com>,
	George Spelvin <linux@sciencehorizons.net>,
	Vegard Nossum <vegard.nossum@gmail.com>,
	ak@linux.intel.com,
	davem@davemloft.net,
	luto@amacapital.net
Return-path: <kernel-hardening-return-5591-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
List-Id: netdev.vger.kernel.org

Hey folks,

I think we're approaching the end of the review for this patchset and we're
getting somewhat close to being ready for it being queued up. At this point,
I've incorporated all of the extremely helpful and instructive suggestions
from the list.

For this v5, we now accept u64[2] as the key, so that alignment is taken
care of naturally. For other alignment issues, we have both the fast aligned
version and the unaligned version, depending on what's necessary. We've
worked out the issues for struct padding. The functions now take a void
pointer to avoid ugly casting, which also helps us shed the inline helper
functions which were not very pretty. The replacements of MD5 have been
benchmarked and show a big increase in speed. We've even come up with a
better naming scheme for dword/qword. All and all it's shaping up nicely.

So, if this series looks good to you, please send along your Reviewed-by,
so we can begin to get this completed. If there are still lingering issues,
let me know and I'll incorporated them into a v6 if necessary.

Thanks,
Jason

Jason A. Donenfeld (4):
  siphash: add cryptographically secure PRF
  siphash: add Nu{32,64} helpers
  secure_seq: use SipHash in place of MD5
  random: use SipHash in place of MD5

 drivers/char/random.c   |  32 +++----
 include/linux/siphash.h |  65 ++++++++++++++
 lib/Kconfig.debug       |   6 +-
 lib/Makefile            |   5 +-
 lib/siphash.c           | 223 ++++++++++++++++++++++++++++++++++++++++++++++++
 lib/test_siphash.c      | 101 ++++++++++++++++++++++
 net/core/secure_seq.c   | 133 +++++++++++------------------
 7 files changed, 460 insertions(+), 105 deletions(-)
 create mode 100644 include/linux/siphash.h
 create mode 100644 lib/siphash.c
 create mode 100644 lib/test_siphash.c

-- 
2.11.0
