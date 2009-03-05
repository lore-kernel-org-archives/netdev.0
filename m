From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 1/13] forcedeth: fix stats version feature
Date: Thu, 05 Mar 2009 13:01:49 -0500
Message-ID: <49B0138D.9000309@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000704030208010807020709"
To: Manfred Spraul <manfred@colorfullife.com>,
	Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
	"David S. Miller" <davem@davemloft.net>,
	nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate03.nvidia.com ([216.228.112.145]:8374 "EHLO
	hqemgate03.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755132AbZCEVBC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2009 16:01:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000704030208010807020709
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Newer versions of the stats feature would not encompass all older 
versions. This would result in only retreiving a subset of all available 
stats in HW.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>


--------------000704030208010807020709
Content-Type: text/plain;
 name="patch-forcedeth-stats"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-stats"

--- old/drivers/net/forcedeth.c	2009-03-04 21:55:19.000000000 -0800
+++ new/drivers/net/forcedeth.c	2009-03-04 21:55:10.000000000 -0800
@@ -87,8 +87,8 @@
 #define DEV_HAS_MSI_X              0x000080  /* device supports MSI-X */
 #define DEV_HAS_POWER_CNTRL        0x000100  /* device supports power savings */
 #define DEV_HAS_STATISTICS_V1      0x000200  /* device supports hw statistics version 1 */
-#define DEV_HAS_STATISTICS_V2      0x000400  /* device supports hw statistics version 2 */
-#define DEV_HAS_STATISTICS_V3      0x000800  /* device supports hw statistics version 3 */
+#define DEV_HAS_STATISTICS_V2      0x000600  /* device supports hw statistics version 2 */
+#define DEV_HAS_STATISTICS_V3      0x000e00  /* device supports hw statistics version 3 */
 #define DEV_HAS_TEST_EXTENDED      0x001000  /* device supports extended diagnostic test */
 #define DEV_HAS_MGMT_UNIT          0x002000  /* device supports management unit */
 #define DEV_HAS_CORRECT_MACADDR    0x004000  /* device supports correct mac address order */
@@ -4796,12 +4796,12 @@
 		else
 			return NV_TEST_COUNT_BASE;
 	case ETH_SS_STATS:
-		if (np->driver_data & DEV_HAS_STATISTICS_V1)
-			return NV_DEV_STATISTICS_V1_COUNT;
+		if (np->driver_data & DEV_HAS_STATISTICS_V3)
+			return NV_DEV_STATISTICS_V3_COUNT;
 		else if (np->driver_data & DEV_HAS_STATISTICS_V2)
 			return NV_DEV_STATISTICS_V2_COUNT;
-		else if (np->driver_data & DEV_HAS_STATISTICS_V3)
-			return NV_DEV_STATISTICS_V3_COUNT;
+		else if (np->driver_data & DEV_HAS_STATISTICS_V1)
+			return NV_DEV_STATISTICS_V1_COUNT;
 		else
 			return 0;
 	default:

--------------000704030208010807020709--
