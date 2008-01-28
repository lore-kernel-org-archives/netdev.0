From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: [PATCH] pktgen: pktgen should not print info that it is spinning
Date: Mon, 28 Jan 2008 13:16:35 -0800
Message-ID: <20080128211635.5907.81831.stgit@jbrandeb-ich9b.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, auke-jan.h.kok@intel.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Robert Olsson <Robert.Olsson@data.slu.se>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:57656 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752245AbYA2Qfk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2008 11:35:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

when using pktgen to send delay packets the module prints repeatedly to the
kernel log:
sleeping for X
sleeping for X
...

This is probably just a debugging item left in and should not be enabled for
regular use of the module.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
CC: Robert Olsson <Robert.Olsson@data.slu.se>
---

 net/core/pktgen.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)


diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 285ec3e..b1b1aba 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2138,7 +2138,6 @@ static void spin(struct pktgen_dev *pkt_dev, __u64 spin_until_us)
 	__u64 now;
 
 	start = now = getCurUs();
-	printk(KERN_INFO "sleeping for %d\n", (int)(spin_until_us - now));
 	while (now < spin_until_us) {
 		/* TODO: optimize sleeping behavior */
 		if (spin_until_us - now > jiffies_to_usecs(1) + 1)

