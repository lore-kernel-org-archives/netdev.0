From: vignesh babu <vignesh.babu@wipro.com>
Subject: [PATCH]is_power_of_2-myri10ge/myri10ge.c
Date: Tue, 12 Jun 2007 10:31:01 +0530
Message-ID: <1181624462.3109.22.camel@merlin.linuxcoe.com>
Reply-To: vignesh.babu@wipro.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Kernel Janitors List <kernel-janitors@lists.osdl.org>
To: akpm <akpm@linux-foundation.org>, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from wip-cdc-wd.wipro.com ([203.91.201.26]:38899 "EHLO
	wip-cdc-wd.wipro.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751448AbXFLFCG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2007 01:02:06 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Replacing (n & (n-1)) in the context of power of 2 checks
with is_power_of_2

Signed-off-by: vignesh babu <vignesh.babu@wipro.com>
--- 
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index b53b7ad..89da958 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -60,6 +60,7 @@
 #include <linux/crc32.h>
 #include <linux/moduleparam.h>
 #include <linux/io.h>
+#include <linux/log2.h>
 #include <net/checksum.h>
 #include <asm/byteorder.h>
 #include <asm/io.h>
@@ -1797,7 +1798,7 @@ static int myri10ge_open(struct net_device *dev)
 	 */
 	big_pow2 = dev->mtu + ETH_HLEN + VLAN_HLEN + MXGEFW_PAD;
 	if (big_pow2 < MYRI10GE_ALLOC_SIZE / 2) {
-		while ((big_pow2 & (big_pow2 - 1)) != 0)
+		while (!is_power_of_2(big_pow2))
 			big_pow2++;
 		mgp->big_bytes = dev->mtu + ETH_HLEN + VLAN_HLEN + MXGEFW_PAD;
 	} else {

-- 
Vignesh Babu BM 
_____________________________________________________________ 
"Why is it that every time I'm with you, makes me believe in magic?"

