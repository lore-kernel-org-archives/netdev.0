From: Rasmus Villemoes <linux-qQsb+v5E8BnlAoU/VqSP6n9LOBIZ5rWg@public.gmane.org>
Subject: [PATCH v3 0/3] Two printf fixes
Date: Tue, 10 Feb 2015 00:44:47 +0100
Message-ID: <1423525491-12613-1-git-send-email-linux@rasmusvillemoes.dk>
References: <1422525801-26560-1-git-send-email-linux@rasmusvillemoes.dk>
Cc: Rasmus Villemoes <linux-qQsb+v5E8BnlAoU/VqSP6n9LOBIZ5rWg@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Andy Shevchenko <andriy.shevchenko-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1422525801-26560-1-git-send-email-linux-qQsb+v5E8BnlAoU/VqSP6n9LOBIZ5rWg@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Both %pE and %ph are unusable in kasprintf(), since the occurrence of
either will trigger an oops during the first vsnprintf call where
kasprintf tries to find the correct size to allocate. These oopses
could be papered over with somewhat smaller patches than these, but
then the return value from vsnprintf would still not reflect the
actual size needed. For %pE, this requires a change of semantics of
string_escape_mem and hence an annoyingly large diffstat.

Not changed in v3: The test_string_escape_nomem helper is still gone,
and the overflow test done in test_string_escape. I also kept the "if
(out + 1 < end)" conditionals that way.

Changed in v3:

* Add Andy's ack to 1/3.

* Ensure that string_escape_mem doesn't output partial escape
  sequences after 2/3, while still preparing for it to do exactly that
  in 3/3.

* Leave the return value of string_escape_mem as int.

v2: Suggestions from Andy Shevchenko:

* Simpler fix of hex_string().

* The string_escape_mem change is split in two, 2/3 updating the
  internal helpers and 3/3 then changing the external interface.


Rasmus Villemoes (3):
  lib/vsprintf.c: Fix potential NULL deref in hex_string
  lib/string_helpers.c: Refactor string_escape_mem
  lib/string_helpers.c: Change semantics of string_escape_mem

 include/linux/string_helpers.h |   8 +-
 lib/string_helpers.c           | 189 ++++++++++++++++-------------------------
 lib/test-string_helpers.c      |  35 ++++----
 lib/vsprintf.c                 |  24 ++++--
 net/sunrpc/cache.c             |   8 +-
 5 files changed, 113 insertions(+), 151 deletions(-)

-- 
2.1.3

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
