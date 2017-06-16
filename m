From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC net-next 8/8] nfp: xdp: report if program is offloaded
Date: Fri, 16 Jun 2017 16:57:46 -0700
Message-ID: <20170616235746.16337-9-jakub.kicinski@netronome.com>
References: <20170616235746.16337-1-jakub.kicinski@netronome.com>
Cc: davem@davemloft.net, kafai@fb.com, daniel@iogearbox.net,
        netoptimizer@brouer.com, oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:34652 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752272AbdFPX6b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 19:58:31 -0400
Received: by mail-pf0-f173.google.com with SMTP id s66so28834047pfs.1
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 16:58:31 -0700 (PDT)
In-Reply-To: <20170616235746.16337-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make use of just added XDP_ATTACHED_HW.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index c5903b6e58c5..cabd117303e1 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -3346,6 +3346,8 @@ static int nfp_net_xdp(struct net_device *netdev, struct netdev_xdp *xdp)
 					 xdp->extack);
 	case XDP_QUERY_PROG:
 		xdp->prog_attached = !!nn->xdp_prog;
+		if (nn->dp.bpf_offload_xdp)
+			xdp->prog_attached = XDP_ATTACHED_HW;
 		xdp->prog_id = nn->xdp_prog ? nn->xdp_prog->aux->id : 0;
 		return 0;
 	default:
-- 
2.11.0
