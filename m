From: "Dmitry V. Levin" <ldv@altlinux.org>
Subject: [PATCH] uapi: fix linux/packet_diag.h userspace compilation error
Date: Tue, 7 Mar 2017 23:50:50 +0300
Message-ID: <20170307205050.GB19323@altlinux.org>
References: <20170228013930.GA28056@altlinux.org> <20170307.121649.968411437349940435.davem@davemloft.net> <20170307202802.GA19323@altlinux.org> <20170307.123535.1895338978981637855.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Emelyanov <xemul@virtuozzo.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170307.123535.1895338978981637855.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace MAX_ADDR_LEN with its numeric value to fix the following
linux/packet_diag.h userspace compilation error:

/usr/include/linux/packet_diag.h:67:17: error: 'MAX_ADDR_LEN' undeclared here (not in a function)
  __u8 pdmc_addr[MAX_ADDR_LEN];

This is not the first case in the UAPI where the numeric value
of MAX_ADDR_LEN is used instead of symbolic one, uapi/linux/if_link.h
already does the same:

$ grep MAX_ADDR_LEN include/uapi/linux/if_link.h 
	__u8 mac[32]; /* MAX_ADDR_LEN */

There are no UAPI headers besides these two that use MAX_ADDR_LEN.

Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>
Acked-by: Pavel Emelyanov <xemul@virtuozzo.com>
---
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
