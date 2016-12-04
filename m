From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net 2/2] bnx2x: Prevent tunnel config for 577xx
Date: Sun, 4 Dec 2016 15:30:18 +0200
Message-ID: <1480858218-13187-3-git-send-email-Yuval.Mintz@cavium.com>
References: <1480858218-13187-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:34103 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751420AbcLDNaf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2016 08:30:35 -0500
In-Reply-To: <1480858218-13187-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only the 578xx adapters are capable of configuring UDP ports for
the purpose of tunnelling - doing the same on 577xx might lead to
a firmware assertion.
We're already not claiming support for any related feature for such
devices, but we also need to prevent the configuration of the UDP
ports to the device in this case.

Fixes: f34fa14cc033 ("bnx2x: Add vxlan RSS support")
Reported-by: Anikina Anna <anikina@gmail.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 0cee4c0..42f4611 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -10138,7 +10138,7 @@ static void __bnx2x_add_udp_port(struct bnx2x *bp, u16 port,
 {
 	struct bnx2x_udp_tunnel *udp_port = &bp->udp_tunnel_ports[type];
 
-	if (!netif_running(bp->dev) || !IS_PF(bp))
+	if (!netif_running(bp->dev) || !IS_PF(bp) || CHIP_IS_E1x(bp))
 		return;
 
 	if (udp_port->count && udp_port->dst_port == port) {
@@ -10163,7 +10163,7 @@ static void __bnx2x_del_udp_port(struct bnx2x *bp, u16 port,
 {
 	struct bnx2x_udp_tunnel *udp_port = &bp->udp_tunnel_ports[type];
 
-	if (!IS_PF(bp))
+	if (!IS_PF(bp) || CHIP_IS_E1x(bp))
 		return;
 
 	if (!udp_port->count || udp_port->dst_port != port) {
-- 
1.9.3
