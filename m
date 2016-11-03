From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 12/13] nfp: remove unnecessary parameters from nfp_net_bpf_offload()
Date: Thu,  3 Nov 2016 13:58:57 +0000
Message-ID: <1478181538-20778-13-git-send-email-jakub.kicinski@netronome.com>
References: <1478181538-20778-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:37383 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757839AbcKCN72 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 09:59:28 -0400
Received: by mail-wm0-f43.google.com with SMTP id t79so102825581wmt.0
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 06:59:27 -0700 (PDT)
In-Reply-To: <1478181538-20778-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nfp_net_bpf_offload() takes all .setup_tc() parameters but it
doesn't use them at the moment.  Remove unnecessary ones to make
it possible for XDP to reuse this function.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h         | 4 +---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c  | 2 +-
 drivers/net/ethernet/netronome/nfp/nfp_net_offload.c | 4 +---
 3 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index abc9e56e93b8..fd29a6306991 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -817,8 +817,6 @@ static inline void nfp_net_debugfs_adapter_del(struct nfp_net *nn)
 #endif /* CONFIG_NFP_NET_DEBUG */
 
 void nfp_net_filter_stats_timer(unsigned long data);
-int
-nfp_net_bpf_offload(struct nfp_net *nn, u32 handle, __be16 proto,
-		    struct tc_cls_bpf_offload *cls_bpf);
+int nfp_net_bpf_offload(struct nfp_net *nn, struct tc_cls_bpf_offload *cls_bpf);
 
 #endif /* _NFP_NET_H_ */
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index fa43dbcecc4f..1e8e00d25c51 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -2694,7 +2694,7 @@ static bool nfp_net_ebpf_capable(struct nfp_net *nn)
 		return -ENOTSUPP;
 
 	if (tc->type == TC_SETUP_CLSBPF && nfp_net_ebpf_capable(nn))
-		return nfp_net_bpf_offload(nn, handle, proto, tc->cls_bpf);
+		return nfp_net_bpf_offload(nn, tc->cls_bpf);
 
 	return -EINVAL;
 }
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c b/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c
index cfed40c0e310..4bb6f16e2a7a 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c
@@ -233,9 +233,7 @@ static int nfp_net_bpf_stop(struct nfp_net *nn)
 	return nfp_net_reconfig(nn, NFP_NET_CFG_UPDATE_GEN);
 }
 
-int
-nfp_net_bpf_offload(struct nfp_net *nn, u32 handle, __be16 proto,
-		    struct tc_cls_bpf_offload *cls_bpf)
+int nfp_net_bpf_offload(struct nfp_net *nn, struct tc_cls_bpf_offload *cls_bpf)
 {
 	struct nfp_bpf_result res;
 	dma_addr_t dma_addr;
-- 
1.9.1
