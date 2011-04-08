From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 2/2] niu: Recognise original ethtool class
 code for AH/ESP flow hashing
Date: Sat, 09 Apr 2011 00:49:15 +0100
Message-ID: <1302306555.2871.59.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Santwona Behera <santwona.behera@sun.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:6453 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752482Ab1DHXtT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2011 19:49:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the RX network flow classification interface was originally
defined for reporting and controlling of flow hashing, AH and ESP were
not given distinct flow class codes (apparently because the Sun
Neptune hardware treats them very similarly).

For flow steering, they must be distinguished, so new and separate
flow class codes were added for AH and ESP.  But for backward-
compatibility, flow hash operations should continue to support the
original class codes.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/niu.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 681a42c..dedca01 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -7022,6 +7022,7 @@ static int niu_ethflow_to_class(int flow_type, u64 *class)
 	case UDP_V4_FLOW:
 		*class = CLASS_CODE_UDP_IPV4;
 		break;
+	case AH_ESP_V4_FLOW:
 	case AH_V4_FLOW:
 	case ESP_V4_FLOW:
 		*class = CLASS_CODE_AH_ESP_IPV4;
@@ -7035,6 +7036,7 @@ static int niu_ethflow_to_class(int flow_type, u64 *class)
 	case UDP_V6_FLOW:
 		*class = CLASS_CODE_UDP_IPV6;
 		break;
+	case AH_ESP_V6_FLOW:
 	case AH_V6_FLOW:
 	case ESP_V6_FLOW:
 		*class = CLASS_CODE_AH_ESP_IPV6;
-- 
1.7.4


-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

