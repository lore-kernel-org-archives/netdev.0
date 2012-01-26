From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH] net: explicitly add jump_label.h header to sock.h
Date: Fri, 27 Jan 2012 02:09:28 +0400
Message-ID: <1327615768-13709-1-git-send-email-glommer@parallels.com>
Cc: geert@linux-m68k.org, netdev@vger.kernel.org, sfr@canb.auug.org.au,
	Glauber Costa <glommer@parallels.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:25982 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752333Ab2AZWJr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jan 2012 17:09:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 36a1211970193ce215de50ed1e4e1272bc814df1 removed linux/module.h
include statement from one of the headers that end up in net/sock.h.
It was providing us with static_branch() definition implicitly, so
after its removal the build got broken.

To fix this, and avoid having this happening in the future,
let me do the right thing and include linux/jump_label.h
explicitly in sock.h.

Signed-off-by: Glauber Costa <glommer@parallels.com>
Reported-by: Randy Dunlap <rdunlap@xenotime.net>
CC: David S. Miller <davem@davemloft.net>
---
 include/net/sock.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 4c69ac1..91c1c8b 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -55,6 +55,7 @@
 #include <linux/uaccess.h>
 #include <linux/memcontrol.h>
 #include <linux/res_counter.h>
+#include <linux/jump_label.h>
 
 #include <linux/filter.h>
 #include <linux/rculist_nulls.h>
-- 
1.7.7.4
