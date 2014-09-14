From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Subject: [PATCH 1/1 v2] netdev: octeon_mgmt: ISO C90 forbids mixed declarations and code
Date: Sun, 14 Sep 2014 07:02:14 +0200
Message-ID: <1410670935-904-1-git-send-email-xypron.glpk@gmx.de>
Cc: "David S. Miller" <davem@davemloft.net>,
	Luka Perkov <luka@openwrt.org>,
	Willem de Bruijn <willemb@google.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Heinrich Schuchardt <xypron.glpk@gmx.de>,
	Joe Perches <joe@perches.com>
To: David Daney <david.daney@cavium.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Revised patch takes into account comments by Joe and David.

Compiling with OCTEON_MGMT_ETHERNET gives a warning
drivers/net/ethernet/octeon/octeon_mgmt.c:295:4:
warning: ISO C90 forbids mixed declarations and code
[-Wdeclaration-after-statement]

The patch cleans up the code.

Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
CC: Joe Perches <joe@perches.com>
CC: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/octeon/octeon_mgmt.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/octeon/octeon_mgmt.c b/drivers/net/ethernet/octeon/octeon_mgmt.c
index 979c698..6cc68b1 100644
--- a/drivers/net/ethernet/octeon/octeon_mgmt.c
+++ b/drivers/net/ethernet/octeon/octeon_mgmt.c
@@ -290,9 +290,10 @@ static void octeon_mgmt_clean_tx_buffers(struct octeon_mgmt *p)
 		/* Read the hardware TX timestamp if one was recorded */
 		if (unlikely(re.s.tstamp)) {
 			struct skb_shared_hwtstamps ts;
+			u64 ns;
 			memset(&ts, 0, sizeof(ts));
 			/* Read the timestamp */
-			u64 ns = cvmx_read_csr(CVMX_MIXX_TSTAMP(p->port));
+			ns = cvmx_read_csr(CVMX_MIXX_TSTAMP(p->port));
 			/* Remove the timestamp from the FIFO */
 			cvmx_write_csr(CVMX_MIXX_TSCTL(p->port), 0);
 			/* Tell the kernel about the timestamp */
-- 
2.1.0
