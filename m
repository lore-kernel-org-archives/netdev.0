From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH iproute2 1/2] tc_core: Use double in tc_core_time2tick()
Date: Tue, 9 Jun 2009 08:05:36 +0000
Message-ID: <20090609080536.GD5237@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Antonio Almeida <vexwek@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Martin Devera <devik@cdi.cz>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Vladimir Ivashchenko <hazard@francoudi.com>,
	Badalian Vyacheslav <slavon@bigtelecom.ru>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f210.google.com ([209.85.219.210]:33173 "EHLO
	mail-ew0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759037AbZFIIFk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 04:05:40 -0400
Received: by mail-ew0-f210.google.com with SMTP id 6so4929033ewy.37
        for <netdev@vger.kernel.org>; Tue, 09 Jun 2009 01:05:42 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change 'time' parameters of tc_core_time2tick() and tc_core_time2big()
from unsigned to double. It is especially needed to use in
tc_calc_rtable() for kernels with increased psched ticks resolution,
but even without this, it looks reasonable to avoid rounding here.

Reported-by: Antonio Almeida <vexwek@gmail.com>
Tested-by: Antonio Almeida <vexwek@gmail.com>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 tc/tc_core.c |   10 +++++-----
 tc/tc_core.h |    4 ++--
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/tc/tc_core.c b/tc/tc_core.c
index 9a0ff39..6d74287 100644
--- a/tc/tc_core.c
+++ b/tc/tc_core.c
@@ -27,18 +27,18 @@
 static double tick_in_usec = 1;
 static double clock_factor = 1;
 
-int tc_core_time2big(unsigned time)
+int tc_core_time2big(double time)
 {
-	__u64 t = time;
+	__u64 t;
 
-	t *= tick_in_usec;
+	t = time * tick_in_usec + 0.5;
 	return (t >> 32) != 0;
 }
 
 
-unsigned tc_core_time2tick(unsigned time)
+unsigned tc_core_time2tick(double time)
 {
-	return time*tick_in_usec;
+	return time * tick_in_usec + 0.5;
 }
 
 unsigned tc_core_tick2time(unsigned tick)
diff --git a/tc/tc_core.h b/tc/tc_core.h
index 5a693ba..0ac65aa 100644
--- a/tc/tc_core.h
+++ b/tc/tc_core.h
@@ -13,8 +13,8 @@ enum link_layer {
 };
 
 
-int  tc_core_time2big(unsigned time);
-unsigned tc_core_time2tick(unsigned time);
+int  tc_core_time2big(double time);
+unsigned tc_core_time2tick(double time);
 unsigned tc_core_tick2time(unsigned tick);
 unsigned tc_core_time2ktime(unsigned time);
 unsigned tc_core_ktime2time(unsigned ktime);
