From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH v3 00/11] rename random32 to prandom and introduce prandom_bytes()
Date: Tue, 13 Nov 2012 22:36:59 +0900
Message-ID: <1352813830-4624-1-git-send-email-akinobu.mita@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Artem Bityutskiy <dedekind1@gmail.com>,
	Adrian Hunter <adrian.hunter@intel.com>,
	David Woodhouse <dwmw2@infradead.org>,
	linux-mtd@lists.infradead.org,
	Eilon Greenstein <eilong@broadcom.com>, netdev@vger.kernel.org,
	Robert Love <robert.w.love@intel.com>, devel@open-fcoe.org,
	Michel Lespinasse <walken@google.com>
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset introduces new functions into random32 library for
getting the requested number of pseudo-random bytes.

Before introducing these new functions into random32 library,
rename all random32 functions to have 'prandom_' prefix.  As a result
the function prototypes are as follows:

void prandom_seed(u32 seed);	/* rename from srandom32() */
u32 prandom_u32(void);		/* rename from random32() */
void prandom_bytes(void *buf, int nbytes);

void prandom_seed_state(struct rnd_state *state, u64 seed);
				/* rename from prandom32_seed() */
u32 prandom_u32_state(struct rnd_state *state);
				/* rename from prandom32() */
void prandom_bytes_state(struct rnd_state *state, void *buf, int nbytes);

The purpose of this renaming is to prevent some kernel developers
from assuming that prandom32() and random32() might imply that only
prandom32() was the one using a pseudo-random number generator by
prandom32's "p", and the result may be a very embarassing security
exposure.  This concern was expressed by Theodore Ts'o.

Changelog

* v3
- change common prefix from 'random32_' to 'prandom_'
- ensure prandom_bytes_state() generates same bytes with same rnd_state

* v2
- rename prandom32 to random32_state
- dropped lib/uuid.c patch
- add bnx2 and mtd_stresstest patches

Akinobu Mita (11):
  random32: rename random32 to prandom
  prandom: introduce prandom_bytes() and prandom_bytes_state()
  bnx2x: use prandom_bytes()
  mtd: nandsim: use prandom_bytes
  ubifs: use prandom_bytes
  mtd: mtd_nandecctest: use prandom_bytes instead of get_random_bytes()
  mtd: mtd_oobtest: convert to use prandom library
  mtd: mtd_pagetest: convert to use prandom library
  mtd: mtd_speedtest: use prandom_bytes
  mtd: mtd_subpagetest: convert to use prandom library
  mtd: mtd_stresstest: use prandom_bytes()

 drivers/mtd/nand/nandsim.c                      |  5 +-
 drivers/mtd/tests/mtd_nandecctest.c             |  2 +-
 drivers/mtd/tests/mtd_oobtest.c                 | 49 ++++---------
 drivers/mtd/tests/mtd_pagetest.c                | 43 ++++-------
 drivers/mtd/tests/mtd_speedtest.c               |  9 +--
 drivers/mtd/tests/mtd_stresstest.c              |  3 +-
 drivers/mtd/tests/mtd_subpagetest.c             | 42 +++--------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |  5 +-
 drivers/scsi/fcoe/fcoe_ctlr.c                   |  4 +-
 fs/ubifs/debug.c                                |  8 +-
 include/linux/random.h                          | 19 +++--
 lib/interval_tree_test_main.c                   |  7 +-
 lib/random32.c                                  | 97 +++++++++++++++++++------
 lib/rbtree_test.c                               |  6 +-
 14 files changed, 145 insertions(+), 154 deletions(-)

Cc: "Theodore Ts'o" <tytso@mit.edu>
Cc: Artem Bityutskiy <dedekind1@gmail.com>
Cc: Adrian Hunter <adrian.hunter@intel.com>
Cc: David Woodhouse <dwmw2@infradead.org>
Cc: linux-mtd@lists.infradead.org
Cc: Eilon Greenstein <eilong@broadcom.com>
Cc: netdev@vger.kernel.org
Cc: Robert Love <robert.w.love@intel.com>
Cc: devel@open-fcoe.org
Cc: Michel Lespinasse <walken@google.com>
-- 
1.7.11.7
