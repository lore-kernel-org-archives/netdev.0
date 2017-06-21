From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] bpf, i40e: Report bpf_prog id during XDP_QUERY_PROG
Date: Wed, 21 Jun 2017 19:27:06 +0200
Message-ID: <754b16a0b2d98a1c6a3796aaa6701fae0c4e2612.1498065586.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>,
        Martin KaFai Lau <kafai@fb.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45495 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751106AbdFUR1T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 13:27:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fill the bpf_prog with the id just like we do in other XDP enabled
drivers.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Cc: Martin KaFai Lau <kafai@fb.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 2db93d3..6f5adb5 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -9589,6 +9589,7 @@ static int i40e_xdp(struct net_device *dev,
 		return i40e_xdp_setup(vsi, xdp->prog);
 	case XDP_QUERY_PROG:
 		xdp->prog_attached = i40e_enabled_xdp_vsi(vsi);
+		xdp->prog_id = xdp->prog_attached ? vsi->xdp_prog->aux->id : 0;
 		return 0;
 	default:
 		return -EINVAL;
-- 
1.9.3
