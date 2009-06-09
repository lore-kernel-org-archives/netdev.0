From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH iproute2 3/2] tc_core: Return double from
	tc_core_tick2time()
Date: Wed, 10 Jun 2009 00:53:46 +0200
Message-ID: <20090609225317.GA3262@ami.dom.local>
References: <20090609080536.GD5237@ff.dom.local> <4A2E6BA4.30002@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Antonio Almeida <vexwek@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Martin Devera <devik@cdi.cz>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Vladimir Ivashchenko <hazard@francoudi.com>,
	Badalian Vyacheslav <slavon@bigtelecom.ru>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:51547 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754771AbZFIWyK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 18:54:10 -0400
Received: by fg-out-1718.google.com with SMTP id 16so113827fgg.17
        for <netdev@vger.kernel.org>; Tue, 09 Jun 2009 15:54:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A2E6BA4.30002@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hmm... I'm not sure this floor() is needed here, but maybe I'll get it
tomorrow... 

Thanks,
Jarek P.
-------------------------->
Patrick McHardy wrote:
> It seems inconsistent to have the time2tick() function take a
> double, but return an unsigned from tick2time(). If we're going
> to change this, please keep them symetrical (you could even use
> floor() in tick2time() to make it more explicit).

This patch removes this inconsistency.

Suggested-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

diff -Nurp a/tc/tc_core.c b/tc/tc_core.c
--- a/tc/tc_core.c	2009-06-09 22:59:42.000000000 +0200
+++ b/tc/tc_core.c	2009-06-10 00:26:10.000000000 +0200
@@ -41,9 +41,9 @@ unsigned tc_core_time2tick(double time)
 	return ceil(time * tick_in_usec);
 }
 
-unsigned tc_core_tick2time(unsigned tick)
+double tc_core_tick2time(unsigned tick)
 {
-	return tick/tick_in_usec;
+	return floor(tick / tick_in_usec);
 }
 
 unsigned tc_core_time2ktime(unsigned time)
diff -Nurp a/tc/tc_core.h b/tc/tc_core.h
--- a/tc/tc_core.h	2009-06-09 22:57:17.000000000 +0200
+++ b/tc/tc_core.h	2009-06-10 00:26:58.000000000 +0200
@@ -15,7 +15,7 @@ enum link_layer {
 
 int  tc_core_time2big(double time);
 unsigned tc_core_time2tick(double time);
-unsigned tc_core_tick2time(unsigned tick);
+double tc_core_tick2time(unsigned tick);
 unsigned tc_core_time2ktime(unsigned time);
 unsigned tc_core_ktime2time(unsigned ktime);
 unsigned tc_calc_xmittime(unsigned rate, unsigned size);
