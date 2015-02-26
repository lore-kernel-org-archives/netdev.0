From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: [PATCH net 3/4] Revert "sh_eth: Enable Rx descriptor word 0 shift
 for r8a7790"
Date: Thu, 26 Feb 2015 14:21:14 +0000
Message-ID: <1424960474.4444.21.camel@xylophone.i.decadent.org.uk>
References: <1424959937.4444.12.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@lists.codethink.co.uk,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	Yoshihiro Kaneko <ykaneko0929@gmail.com>,
	Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:34918 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751597AbbBZOVT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 09:21:19 -0500
In-Reply-To: <1424959937.4444.12.camel@xylophone.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit fd9af07c3404ac9ecbd0d859563360f51ce1ffde.

The hardware manual states that the frame error and multicast bits are
copied to bits 9:0 of RD0, not bits 25:16.  I've tested that this is
true for RFS1 (CRC error), RFS3 (frame too short), RFS4 (frame too
long) and RFS8 (multicast).

Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
---
 drivers/net/ethernet/renesas/sh_eth.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index ed67951f5271..317722e16043 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -508,7 +508,6 @@ static struct sh_eth_cpu_data r8a779x_data = {
 	.tpauser	= 1,
 	.hw_swap	= 1,
 	.rmiimode	= 1,
-	.shift_rd0	= 1,
 };
 
 static void sh_eth_set_rate_sh7724(struct net_device *ndev)
@@ -1459,8 +1458,8 @@ static int sh_eth_rx(struct net_device *ndev, u32 intr_status, int *quota)
 
 		/* In case of almost all GETHER/ETHERs, the Receive Frame State
 		 * (RFS) bits in the Receive Descriptor 0 are from bit 9 to
-		 * bit 0. However, in case of the R8A7740, R8A779x, and
-		 * R7S72100 the RFS bits are from bit 25 to bit 16. So, the
+		 * bit 0. However, in case of the R8A7740 and R7S72100
+		 * the RFS bits are from bit 25 to bit 16. So, the
 		 * driver needs right shifting by 16.
 		 */
 		if (mdp->cd->shift_rd0)
-- 
1.7.10.4
