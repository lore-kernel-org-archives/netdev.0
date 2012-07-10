From: Li Wei <lw@cn.fujitsu.com>
Subject: [PATCH] tc: filter: validate filter priority in userspace.
Date: Tue, 10 Jul 2012 16:45:28 +0800
Message-ID: <4FFBEBA8.1050802@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58868 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753392Ab2GJI7f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2012 04:59:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Because we use the high 16 bits of tcm_info to pass prio value to
kernel, thus it's range would be [0, 0xffff], without validation
in tc when user pass a lager(>65535) priority, the actual priority
set in kernel would confuse the user.

So, add a validation to ensure prio in the range.
---
 tc/tc_filter.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tc/tc_filter.c b/tc/tc_filter.c
index 207302f..04c3b82 100644
--- a/tc/tc_filter.c
+++ b/tc/tc_filter.c
@@ -105,7 +105,7 @@ int tc_filter_modify(int cmd, unsigned flags, int argc, char **argv)
 			NEXT_ARG();
 			if (prio)
 				duparg("priority", *argv);
-			if (get_u32(&prio, *argv, 0))
+			if (get_u32(&prio, *argv, 0) || prio > 0xFFFF)
 				invarg(*argv, "invalid priority value");
 		} else if (matches(*argv, "protocol") == 0) {
 			__u16 id;
-- 
1.7.1
