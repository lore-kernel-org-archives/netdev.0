From: "Seymour, Shane M" <shane.seymour@hpe.com>
Subject: [PATCH net-next] tcp: increase size at which tcp_bound_to_half_wnd
 bounds to > TCP_MSS_DEFAULT
Date: Tue, 28 Jun 2016 04:33:30 +0000
Message-ID: <CS1PR84MB0295E420892A535E40FE338EFD220@CS1PR84MB0295.NAMPRD84.PROD.OUTLOOK.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bn0107.outbound.protection.outlook.com ([157.56.110.107]:8962
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751017AbcF1GIr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 02:08:47 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In previous commit 01f83d69844d307be2aa6fea88b0e8fe5cbdb2f4
the following comments were added:

"When peer uses tiny windows, there is no use in packetizing to sub-MSS
pieces for the sake of SWS or making sure there are enough packets in
the pipe for fast recovery."

The test should be > TCP_MSS_DEFAULT not >= 512. This allows low end
devices that send an MSS of 536 (TCP_MSS_DEFAULT) to see better network
performance by sending it 536 bytes of data at a time instead of bounding
to half window size (268). Other network stacks work this way, e.g. HP-UX.

Signed-off-by: Shane Seymour <shane.seymour@hpe.com>
---
--- b/include/net/tcp.h	2016-06-23 20:59:14.521686048 -0500
+++ a/include/net/tcp.h	2016-06-15 17:19:21.964821477 -0500
@@ -589,7 +589,7 @@ static inline int tcp_bound_to_half_wnd(
 	 * On the other hand, for extremely large MSS devices, handling
 	 * smaller than MSS windows in this way does make sense.
 	 */
-	if (tp->max_window > TCP_MSS_DEFAULT)
+	if (tp->max_window >= 512)
 		cutoff = (tp->max_window >> 1);
 	else
 		cutoff = tp->max_window;
