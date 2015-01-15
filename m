From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2 2/2] lib: fix setns() function when !HAVE_SETNS
Date: Thu, 15 Jan 2015 11:36:25 +0100
Message-ID: <1421318185-10858-2-git-send-email-nicolas.dichtel@6wind.com>
References: <1421318185-10858-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Vadim Kochan <vadim4j@gmail.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:48905 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751946AbbAOKgq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 05:36:46 -0500
In-Reply-To: <1421318185-10858-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When HAVE_SETNS is not set, iproute2 provides a local implementation of this
function based on __NR_setns.
This macro is defined in sys/syscall.h, which was not included, thus the local
implementation always returned -1.

CC: Vadim Kochan <vadim4j@gmail.com>
Fixes: eb67e4498aec ("lib: Add netns_switch func for change network namespace")
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/namespace.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/namespace.h b/include/namespace.h
index 28a4223b3eb2..52f7fbd7bb8c 100644
--- a/include/namespace.h
+++ b/include/namespace.h
@@ -3,6 +3,7 @@
 
 #include <sched.h>
 #include <sys/mount.h>
+#include <sys/syscall.h>
 #include <errno.h>
 
 #define NETNS_RUN_DIR "/var/run/netns"
-- 
2.1.0
