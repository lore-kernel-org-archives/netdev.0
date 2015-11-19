From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net] bnx2x: Fix vxlan removal
Date: Thu, 19 Nov 2015 11:56:51 +0200
Message-ID: <1447927011-3282-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Jiri Benc <jbenc@redhat.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:22967 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756515AbbKSJ5C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 04:57:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commmit ac7eccd4d48fc "bnx2x: track vxlan port count" contains a bug -
Instead of achieving the required goal, vxlan configuration would not
be removed since we're decrementing the port instead of the counter.

CC: Jiri Benc <jbenc@redhat.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
Hi Dave,

Please consider applying this to `net'.

Thanks,
Yuval
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index c9b0367..2e611dc 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -10139,8 +10139,8 @@ static void __bnx2x_del_vxlan_port(struct bnx2x *bp, u16 port)
 		DP(BNX2X_MSG_SP, "Invalid vxlan port\n");
 		return;
 	}
-	bp->vxlan_dst_port--;
-	if (bp->vxlan_dst_port)
+	bp->vxlan_dst_port_count--;
+	if (bp->vxlan_dst_port_count)
 		return;
 
 	if (netif_running(bp->dev)) {
-- 
1.9.3
