From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 8/8] nfp: xdp: report if program is offloaded
Date: Wed, 21 Jun 2017 18:25:10 -0700
Message-ID: <20170622012510.5286-9-jakub.kicinski@netronome.com>
References: <20170622012510.5286-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kafai@fb.com, daniel@iogearbox.net,
        davem@davemloft.net, Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:36743 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752006AbdFVB0J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 21:26:09 -0400
Received: by mail-pg0-f44.google.com with SMTP id u62so1183446pgb.3
        for <netdev@vger.kernel.org>; Wed, 21 Jun 2017 18:26:08 -0700 (PDT)
In-Reply-To: <20170622012510.5286-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make use of just added XDP_ATTACHED_HW.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index c9fc1df1823e..2134493ec8a8 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -3341,6 +3341,8 @@ static int nfp_net_xdp(struct net_device *netdev, struct netdev_xdp *xdp)
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
