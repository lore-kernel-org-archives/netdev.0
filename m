From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH] Switch helpers tc_core_{time2ktime,ktime2time} from long to unsigned as well.
Date: Fri, 12 Oct 2007 13:49:49 +0200
Message-ID: <1192189789-23538-1-git-send-email-andreas@fatal.se>
Cc: netdev@vger.kernel.org, Andreas Henriksson <andreas@fatal.se>
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1-1-1-9a.ghn.gbg.bostream.se ([82.182.69.4]:50390 "EHLO
	scream.fatal.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755163AbXJLLua (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 07:50:30 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Follow up patch to "Fix overflow in time2tick / tick2time." which switches
the remaining two helper functions from long to unsigned as well.
These functions are only used in "tc/q_hfsc.c" where both the passed argument
and the place the return value is stored are unsigned/u32 variables, so this
change should be safe to make but hasn't been tested as extensively as the
time2tick patch.

Signed-off-by: Andreas Henriksson <andreas@fatal.se>
---
 tc/tc_core.c |    4 ++--
 tc/tc_core.h |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/tc/tc_core.c b/tc/tc_core.c
index fb89876..8c3a2ac 100644
--- a/tc/tc_core.c
+++ b/tc/tc_core.c
@@ -45,12 +45,12 @@ unsigned tc_core_tick2time(unsigned tick)
 	return tick/tick_in_usec;
 }
 
-long tc_core_time2ktime(long time)
+unsigned tc_core_time2ktime(unsigned time)
 {
 	return time * clock_factor;
 }
 
-long tc_core_ktime2time(long ktime)
+unsigned tc_core_ktime2time(unsigned ktime)
 {
 	return ktime / clock_factor;
 }
diff --git a/tc/tc_core.h b/tc/tc_core.h
index b2a16bc..b1ede1e 100644
--- a/tc/tc_core.h
+++ b/tc/tc_core.h
@@ -9,8 +9,8 @@
 int  tc_core_time2big(long time);
 unsigned tc_core_time2tick(unsigned time);
 unsigned tc_core_tick2time(unsigned tick);
-long tc_core_time2ktime(long time);
-long tc_core_ktime2time(long ktime);
+unsigned tc_core_time2ktime(unsigned time);
+unsigned tc_core_ktime2time(unsigned ktime);
 unsigned tc_calc_xmittime(unsigned rate, unsigned size);
 unsigned tc_calc_xmitsize(unsigned rate, unsigned ticks);
 int tc_calc_rtable(unsigned bps, __u32 *rtab, int cell_log, unsigned mtu, unsigned mpu);
-- 
1.5.3.4

