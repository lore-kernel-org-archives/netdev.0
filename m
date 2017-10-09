From: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
Subject: [PATCH] net: thunderx: mark expected switch fall-throughs in
 nicvf_main()
Date: Mon, 9 Oct 2017 11:44:53 -0500
Message-ID: <20171009164453.GA4889@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <gustavo@embeddedor.com>
To: Sunil Goutham <sgoutham@cavium.com>,
        Robert Richter <rric@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation to enabling -Wimplicit-fallthrough, mark switch cases
where we are expecting to fall through.

Cc: Sunil Goutham <sgoutham@cavium.com>
Cc: Robert Richter <rric@kernel.org>
Cc: linux-arm-kernel@lists.infradead.org
Cc: netdev@vger.kernel.org
Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>
---
 drivers/net/ethernet/cavium/thunder/nicvf_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index d68478a..71989e1 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -566,8 +566,10 @@ static inline bool nicvf_xdp_rx(struct nicvf *nic, struct bpf_prog *prog,
 		return true;
 	default:
 		bpf_warn_invalid_xdp_action(action);
+		/* fall through */
 	case XDP_ABORTED:
 		trace_xdp_exception(nic->netdev, prog, action);
+		/* fall through */
 	case XDP_DROP:
 		/* Check if it's a recycled page, if not
 		 * unmap the DMA mapping.
-- 
2.7.4
