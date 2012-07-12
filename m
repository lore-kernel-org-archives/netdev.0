From: Li Wei <lw@cn.fujitsu.com>
Subject: [PATCH] tc: man: change man page and comment to confirm to code's
 behavior.
Date: Thu, 12 Jul 2012 09:56:57 +0800
Message-ID: <4FFE2EE9.8030808@cn.fujitsu.com>
References: <4FFD2A42.9080507@cn.fujitsu.com> <20120711075129.4f81eea8@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:3354 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756498Ab2GLB5m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2012 21:57:42 -0400
In-Reply-To: <20120711075129.4f81eea8@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Since the get_rate() code incorrectly interpreted bare number, the
behavior is not the same as man page and comment described.

We need to change the man page and comment for compatible with the
existing usage by scripts.
---
 man/man8/tc.8 |    7 +++++--
 tc/tc_util.c  |    2 +-
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/man/man8/tc.8 b/man/man8/tc.8
index 958ab98..f0e5613 100644
--- a/man/man8/tc.8
+++ b/man/man8/tc.8
@@ -259,6 +259,9 @@ All parameters accept a floating point number, possibly followed by a unit.
 .P
 Bandwidths or rates can be specified in:
 .TP
+bps
+Bytes per second
+.TP
 kbps
 Kilobytes per second
 .TP
@@ -271,8 +274,8 @@ Kilobits per second
 mbit
 Megabits per second
 .TP
-bps or a bare number
-Bytes per second
+bit or a bare number
+Bits per second
 .P
 Amounts of data can be specified in:
 .TP
diff --git a/tc/tc_util.c b/tc/tc_util.c
index 926ed08..ccf8fa4 100644
--- a/tc/tc_util.c
+++ b/tc/tc_util.c
@@ -153,7 +153,7 @@ int get_rate(unsigned *rate, const char *str)
 		return -1;
 
 	if (*p == '\0') {
-		*rate = bps / 8.;	/* assume bytes/sec */
+		*rate = bps / 8.;	/* assume bits/sec */
 		return 0;
 	}
 
-- 
1.7.1
