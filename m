From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH iproute2] configure: add missing INCLUDE to netnsid detection
Date: Wed,  8 Apr 2015 21:42:00 +0200
Message-ID: <42d42073b18a4cc0aebbc912fcc14788693c0c75.1428522001.git.jbenc@redhat.com>
Cc: Vadim Kochan <vadim4j@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59688 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753528AbbDHTmi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Apr 2015 15:42:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: d116ff34145b0 ("ip netns: Fix rtnl error while print netns list")
Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
The whole check added by d116ff34145b0 is dubious, though. This should be
a run time check, not a compile time one.
---
 configure | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/configure b/configure
index 631938e97206..e54f4b6db5e8 100755
--- a/configure
+++ b/configure
@@ -224,7 +224,7 @@ check_netnsid()
 #include <linux/rtnetlink.h>
 int test_def = RTM_GETNSID;
 EOF
-    $CC -c $TMPDIR/netnsid.c >/dev/null 2>&1
+    $CC -I$INCLUDE -c $TMPDIR/netnsid.c >/dev/null 2>&1
     if [ $? -eq 0 ]
     then
 	echo "IP_CONFIG_NETNSID:=y" >> Config
-- 
1.8.3.1
