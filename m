From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH v7 0/6] The SipHash Patchset
Date: Thu, 22 Dec 2016 00:02:10 +0100
Message-ID: <20161221230216.25341-1-Jason@zx2c4.com>
References: <20161216030328.11602-1-Jason@zx2c4.com>
Reply-To: kernel-hardening@lists.openwall.com
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>
To: Netdev <netdev@vger.kernel.org>,
	kernel-hardening@lists.openwall.com,
	LKML <linux-kernel@vger.kernel.org>,
	linux-crypto@vger.kernel.org,
	David Laight <David.Laight@aculab.com>,
	Ted Tso <tytso@mit.edu>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	edumazet@google.com,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Eric Biggers <ebiggers3@gmail.com>,
	Tom Herbert <tom@herbertland.com>,
	ak@linux.intel.com,
	davem@davemloft.net,
	luto@amacapital.net,
	Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
Return-path: <kernel-hardening-return-5747-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20161216030328.11602-1-Jason@zx2c4.com>
List-Id: netdev.vger.kernel.org

Hey folks,

Again we've made huge progress, with this latest version now shipping
Jean-Phillipe Aumasson's HalfSipHash, which should be much more competitive
with jhash (in addition to being more secure, of course).

There are dozens of little cleanups and improvements right and left throughout
this series, so I urge you to take a look at the whole thing. I've tried to
take into consideration lots of concerns and suggestions from many of you
over the last week.

There is also now documentation! And the test suite now has full coverage of
all functions.

Finally, there's been some significant benchmarking, and now a few commit
messages have some performance numbers.

Please send your Reviewed-by lines as you see fit.

Regards,
Jason

Jason A. Donenfeld (6):
  siphash: add cryptographically secure PRF
  secure_seq: use SipHash in place of MD5
  random: use SipHash in place of MD5
  md5: remove from lib and only live in crypto
  syncookies: use SipHash in place of SHA1
  siphash: implement HalfSipHash1-3 for hash tables

 Documentation/siphash.txt | 154 +++++++++++++
 MAINTAINERS               |   7 +
 crypto/md5.c              |  95 +++++++-
 drivers/char/random.c     |  84 ++++---
 include/linux/random.h    |   1 -
 include/linux/siphash.h   | 133 +++++++++++
 init/main.c               |   1 -
 lib/Kconfig.debug         |   6 +-
 lib/Makefile              |   7 +-
 lib/md5.c                 |  95 --------
 lib/siphash.c             | 548 ++++++++++++++++++++++++++++++++++++++++++++++
 lib/test_siphash.c        | 208 ++++++++++++++++++
 net/core/secure_seq.c     | 135 +++++-------
 net/ipv4/syncookies.c     |  20 +-
 net/ipv6/syncookies.c     |  37 ++--
 15 files changed, 1274 insertions(+), 257 deletions(-)
 create mode 100644 Documentation/siphash.txt
 create mode 100644 include/linux/siphash.h
 delete mode 100644 lib/md5.c
 create mode 100644 lib/siphash.c
 create mode 100644 lib/test_siphash.c

-- 
2.11.0
