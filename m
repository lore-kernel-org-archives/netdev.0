From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] net: ifdef NET_TX_SOFTIRQ, NET_RX_SOFTIRQ
Date: Fri, 21 Nov 2008 07:58:59 +0300
Message-ID: <20081121045859.GA5625@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:42406 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751761AbYKUEzP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 23:55:15 -0500
Received: by ug-out-1314.google.com with SMTP id 39so19638ugf.37
        for <netdev@vger.kernel.org>; Thu, 20 Nov 2008 20:55:13 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that number of softirqs actually matters (see NR_SOFTIRQS), it makes
sense to not add networking ones when not needed.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/linux/interrupt.h |    2 ++
 1 file changed, 2 insertions(+)

--- a/include/linux/interrupt.h
+++ b/include/linux/interrupt.h
@@ -246,8 +246,10 @@ enum
 {
 	HI_SOFTIRQ=0,
 	TIMER_SOFTIRQ,
+#ifdef CONFIG_NET
 	NET_TX_SOFTIRQ,
 	NET_RX_SOFTIRQ,
+#endif
 	BLOCK_SOFTIRQ,
 	TASKLET_SOFTIRQ,
 	SCHED_SOFTIRQ,
