From: Li Wei <lw@cn.fujitsu.com>
Subject: [PATCH] tc_util: fix incorrect bare number process in get_rate.
Date: Wed, 11 Jul 2012 15:24:50 +0800
Message-ID: <4FFD2A42.9080507@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:1168 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754158Ab2GKHZe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2012 03:25:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


As the comment and manpage indicated that the bare number means
bytes per second, so the division is not needed.
---
 tc/tc_util.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tc/tc_util.c b/tc/tc_util.c
index 926ed08..e8d89c1 100644
--- a/tc/tc_util.c
+++ b/tc/tc_util.c
@@ -153,7 +153,7 @@ int get_rate(unsigned *rate, const char *str)
 		return -1;
 
 	if (*p == '\0') {
-		*rate = bps / 8.;	/* assume bytes/sec */
+		*rate = bps;	/* assume bytes/sec */
 		return 0;
 	}
 
-- 
1.7.1
