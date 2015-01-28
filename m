From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH 0/2] Two printf fixes
Date: Wed, 28 Jan 2015 14:25:40 +0100
Message-ID: <1422451543-12401-1-git-send-email-linux@rasmusvillemoes.dk>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Trond Myklebust <trond.myklebust@primarydata.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Both %pE and %ph are unusable in kasprintf(), since the occurrence of
either will trigger an oops during the first vsnprintf call where
kasprintf tries to find the correct size to allocate. These oopses
could be papered over with somewhat smaller patches than these, but
then the return value from vsnprintf would still not reflect the
actual size needed. For %pE, this requires a change of semantics of
string_escape_mem and hence an annoyingly large diffstat.

Whether this is 3.20, 3.21 and/or -stable material (or /dev/null
material, for that matter ;-)) I'll leave to others to decide.

Rasmus Villemoes (2):
  lib/vsprintf.c: Fix potential NULL deref in hex_string
  string_helpers: Change semantics of string_escape_mem

 include/linux/string_helpers.h |  10 +--
 lib/string_helpers.c           | 195 ++++++++++++++++-------------------------
 lib/test-string_helpers.c      |  37 ++++----
 lib/vsprintf.c                 |  25 ++++--
 net/sunrpc/cache.c             |   8 +-
 5 files changed, 119 insertions(+), 156 deletions(-)

-- 
2.1.3
