From: Robert Jennings <rcj@linux.vnet.ibm.com>
Subject: [PATCH] ibmveth: Increase default copybreak limits to 2k
Date: Thu, 21 Oct 2010 09:37:53 -0500
Message-ID: <20101021143753.GA5567@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:39620 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751080Ab0JUOhz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 10:37:55 -0400
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e31.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o9LEP7A7002525
	for <netdev@vger.kernel.org>; Thu, 21 Oct 2010 08:25:07 -0600
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o9LEbspU186542
	for <netdev@vger.kernel.org>; Thu, 21 Oct 2010 08:37:54 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o9LEfmQc024689
	for <netdev@vger.kernel.org>; Thu, 21 Oct 2010 08:41:48 -0600
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Increase the copybreak limits for rx and tx from 128 bytes
to 2048 bytes. These limits were added by commits
8d86c61ae41d9068fd5e5cc01a4abd53c4fe3ab5 and
c08cc3ccebd46dce44d13a8ce81d249e687eeb8a to make use of a
bounce buffer for packets below 128 bytes.  This avoids
tearing down and creating a TCE entry.

Performance testing shows that this default limit can be
increased from 128 to 2048 for both rx and tx copybreak.
This resulted in ~10% throughput increase for for packets
that fit this limit without affecting performance for larger
packets.

Signed-off-by: Robert Jennings <rcj@linux.vnet.ibm.com>
---
 drivers/net/ibmveth.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
index c454b45..20b7a98 100644
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -65,12 +65,12 @@ MODULE_DESCRIPTION("IBM Power Virtual Ethernet Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(ibmveth_driver_version);
 
-static unsigned int tx_copybreak __read_mostly = 128;
+static unsigned int tx_copybreak __read_mostly = 2048;
 module_param(tx_copybreak, uint, 0644);
 MODULE_PARM_DESC(tx_copybreak,
 	"Maximum size of packet that is copied to a new buffer on transmit");
 
-static unsigned int rx_copybreak __read_mostly = 128;
+static unsigned int rx_copybreak __read_mostly = 2048;
 module_param(rx_copybreak, uint, 0644);
 MODULE_PARM_DESC(rx_copybreak,
 	"Maximum size of packet that is copied to a new buffer on receive");
-- 
1.7.0.4

