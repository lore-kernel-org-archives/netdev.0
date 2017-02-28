From: "Dmitry V. Levin" <ldv@altlinux.org>
Subject: [RFC PATCH] uapi: fix linux/packet_diag.h userspace compilation error
Date: Tue, 28 Feb 2017 04:39:30 +0300
Message-ID: <20170228013930.GA28056@altlinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pavel Emelyanov <xemul@parallels.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vmicros1.altlinux.org ([194.107.17.57]:49480 "EHLO
        vmicros1.altlinux.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751556AbdB1Bl3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 20:41:29 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace MAX_ADDR_LEN with its numeric value to fix the following
linux/packet_diag.h userspace compilation error:

/usr/include/linux/packet_diag.h:67:17: error: 'MAX_ADDR_LEN' undeclared here (not in a function)
  __u8 pdmc_addr[MAX_ADDR_LEN];

This is not the first case in the UAPI where the numeric value
of MAX_ADDR_LEN is used, uapi/linux/if_link.h already does the same,
and there are no UAPI headers besides these two that use MAX_ADDR_LEN.

The alternative fix would be to include <linux/netdevice.h> which
pulls in other headers and a lot of definitions with them.

Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>
---
I'm not quite comfortable with this approach but the alternative
has its own drawbacks.

 include/uapi/linux/packet_diag.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/uapi/linux/packet_diag.h b/include/uapi/linux/packet_diag.h
index d08c63f..0c5d5dd 100644
--- a/include/uapi/linux/packet_diag.h
+++ b/include/uapi/linux/packet_diag.h
@@ -64,7 +64,7 @@ struct packet_diag_mclist {
 	__u32	pdmc_count;
 	__u16	pdmc_type;
 	__u16	pdmc_alen;
-	__u8	pdmc_addr[MAX_ADDR_LEN];
+	__u8	pdmc_addr[32]; /* MAX_ADDR_LEN */
 };
 
 struct packet_diag_ring {
-- 
ldv
