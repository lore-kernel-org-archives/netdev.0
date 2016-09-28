From: Sushma Sitaram <sushma.sitaram@intel.com>
Subject: [PATCH] tc: f_u32: Fill in 'linkid' provided by user
Date: Wed, 28 Sep 2016 11:30:16 -0700
Message-ID: <20160928183016.23280.39364.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com
To: stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:40664 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754461AbcI1S2E (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 28 Sep 2016 14:28:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, 'linkid' input by the user is parsed but 'handle' is appended to the netlink message.

# tc filter add dev enp1s0f1 protocol ip parent ffff: prio 99 u32 ht 800: \
	order 1 link 1: offset at 0 mask 0f00 shift 6 plus 0 eat match ip \
	protocol 6 ff

resulted in:
filter protocol ip pref 99 u32 fh 800::1 order 1 key ht 800 bkt 0
  match 00060000/00ff0000 at 8
    offset 0f00>>6 at 0  eat

This patch results in:
filter protocol ip pref 99 u32 fh 800::1 order 1 key ht 800 bkt 0 link 1:
  match 00060000/00ff0000 at 8
    offset 0f00>>6 at 0  eat


Signed-off-by Sushma Sitaram: Sushma Sitaram <sushma.sitaram@intel.com>
---
 tc/f_u32.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tc/f_u32.c b/tc/f_u32.c
index 0ad7ed2..92c1fcd 100644
--- a/tc/f_u32.c
+++ b/tc/f_u32.c
@@ -1071,7 +1071,7 @@ static int u32_parse_opt(struct filter_util *qu, char *handle,
 				fprintf(stderr, "\"link\" must be a hash table.\n");
 				return -1;
 			}
-			addattr_l(n, MAX_MSG, TCA_U32_LINK, &handle, 4);
+			addattr_l(n, MAX_MSG, TCA_U32_LINK, &linkid, 4);
 		} else if (strcmp(*argv, "ht") == 0) {
 			unsigned int ht;
 
