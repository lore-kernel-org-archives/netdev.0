From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] retain ABI definitions for obsolete multi-queue packet
 schedulers
Date: Fri, 12 Sep 2008 10:00:11 -0700
Message-ID: <20080912100011.10c5c6b8@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44980 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756958AbYILRJw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Sep 2008 13:09:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Even though the sch_rr qdisc is now gone in 2.6.27, the kernel
definitions for the attributes need to be maintained because applications
like iproute need to be compatible with older kernels and use santized
kernel headers.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/include/linux/pkt_sched.h	2008-09-12 09:56:39.000000000 -0700
+++ b/include/linux/pkt_sched.h	2008-09-12 09:57:49.000000000 -0700
@@ -123,6 +123,16 @@ struct tc_prio_qopt
 	__u8	priomap[TC_PRIO_MAX+1];	/* Map: logical priority -> PRIO band */
 };
 
+/* Obsolete option from original multiqueue */
+enum
+{
+	TCA_PRIO_UNSPEC,
+	TCA_PRIO_MQ,
+	__TCA_PRIO_MAX
+};
+
+#define TCA_PRIO_MAX    (__TCA_PRIO_MAX - 1)
+
 /* TBF section */
 
 struct tc_tbf_qopt
