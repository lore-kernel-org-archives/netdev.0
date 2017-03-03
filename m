From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net 2/2] sfc: fix IPID endianness in TSOv2
Date: Fri, 3 Mar 2017 15:22:27 +0000
Message-ID: <9fdc671c-9297-d1e2-51ff-5fc264fd0e9d@solarflare.com>
References: <0750d060-35d1-c221-f866-fba825e3947e@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:49303 "EHLO
        nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752344AbdCCPXW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Mar 2017 10:23:22 -0500
In-Reply-To: <0750d060-35d1-c221-f866-fba825e3947e@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The value we read from the header is in network byte order, whereas
 EFX_POPULATE_QWORD_* takes values in host byte order (which it then
 converts to little-endian, as MCDI is little-endian).

Fixes: e9117e5099ea ("sfc: Firmware-Assisted TSO version 2")
Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 4d88e85..c60c2d4 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -2183,7 +2183,7 @@ static int efx_ef10_tx_tso_desc(struct efx_tx_queue *tx_queue,
 		/* Modify IPv4 header if needed. */
 		ip->tot_len = 0;
 		ip->check = 0;
-		ipv4_id = ip->id;
+		ipv4_id = ntohs(ip->id);
 	} else {
 		/* Modify IPv6 header if needed. */
 		struct ipv6hdr *ipv6 = ipv6_hdr(skb);
