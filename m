From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH 11/12] Fix overflow in time2tick / tick2time.
Date: Fri, 12 Oct 2007 10:56:46 +0200
Message-ID: <1192179407-22461-11-git-send-email-andreas@fatal.se>
References: <1192179407-22461-1-git-send-email-andreas@fatal.se>
 <1192179407-22461-2-git-send-email-andreas@fatal.se>
 <1192179407-22461-3-git-send-email-andreas@fatal.se>
 <1192179407-22461-4-git-send-email-andreas@fatal.se>
 <1192179407-22461-5-git-send-email-andreas@fatal.se>
 <1192179407-22461-6-git-send-email-andreas@fatal.se>
 <1192179407-22461-7-git-send-email-andreas@fatal.se>
 <1192179407-22461-8-git-send-email-andreas@fatal.se>
 <1192179407-22461-9-git-send-email-andreas@fatal.se>
 <1192179407-22461-10-git-send-email-andreas@fatal.se>
Cc: netdev@vger.kernel.org, Andreas Henriksson <andreas@fatal.se>
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1-1-1-9a.ghn.gbg.bostream.se ([82.182.69.4]:55352 "EHLO
	scream.fatal.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750906AbXJLJGh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 05:06:37 -0400
In-Reply-To: <1192179407-22461-10-git-send-email-andreas@fatal.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The helper functions gets passed an unsigned int, which gets cast to long
and overflows. See http://bugs.debian.org/175462

Signed-off-by: Andreas Henriksson <andreas@fatal.se>
---
 tc/tc_core.c |    4 ++--
 tc/tc_core.h |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/tc/tc_core.c b/tc/tc_core.c
index 58155fb..fb89876 100644
--- a/tc/tc_core.c
+++ b/tc/tc_core.c
@@ -35,12 +35,12 @@ int tc_core_time2big(long time)
 }
 
 
-long tc_core_time2tick(long time)
+unsigned tc_core_time2tick(unsigned time)
 {
 	return time*tick_in_usec;
 }
 
-long tc_core_tick2time(long tick)
+unsigned tc_core_tick2time(unsigned tick)
 {
 	return tick/tick_in_usec;
 }
diff --git a/tc/tc_core.h b/tc/tc_core.h
index a139da6..b2a16bc 100644
--- a/tc/tc_core.h
+++ b/tc/tc_core.h
@@ -7,8 +7,8 @@
 #define TIME_UNITS_PER_SEC	1000000
 
 int  tc_core_time2big(long time);
-long tc_core_time2tick(long time);
-long tc_core_tick2time(long tick);
+unsigned tc_core_time2tick(unsigned time);
+unsigned tc_core_tick2time(unsigned tick);
 long tc_core_time2ktime(long time);
 long tc_core_ktime2time(long ktime);
 unsigned tc_calc_xmittime(unsigned rate, unsigned size);
-- 
1.5.3.4

