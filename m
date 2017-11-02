From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 3/8] nfp: bpf: reject TC offload if XDP loaded
Date: Thu,  2 Nov 2017 01:31:31 -0700
Message-ID: <20171102083136.2096-4-jakub.kicinski@netronome.com>
References: <20171102083136.2096-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:52641 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755419AbdKBIcZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2017 04:32:25 -0400
Received: by mail-pg0-f66.google.com with SMTP id a192so4432811pge.9
        for <netdev@vger.kernel.org>; Thu, 02 Nov 2017 01:32:24 -0700 (PDT)
In-Reply-To: <20171102083136.2096-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recent TC changes dropped the check protecting us from trying
to offload a TC program if XDP programs are already loaded.

Fixes: 90d97315b3e7 ("nfp: bpf: Convert ndo_setup_tc offloads to block callbacks")
Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/bpf/main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/netronome/nfp/bpf/main.c b/drivers/net/ethernet/netronome/nfp/bpf/main.c
index 04424db24b80..8e3e89cace8d 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/main.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/main.c
@@ -130,6 +130,9 @@ static int nfp_bpf_setup_tc_block_cb(enum tc_setup_type type,
 		    cls_bpf->common.protocol != htons(ETH_P_ALL) ||
 		    cls_bpf->common.chain_index)
 			return -EOPNOTSUPP;
+		if (nn->dp.bpf_offload_xdp)
+			return -EBUSY;
+
 		return nfp_net_bpf_offload(nn, cls_bpf);
 	default:
 		return -EOPNOTSUPP;
-- 
2.14.1
