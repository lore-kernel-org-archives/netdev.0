From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/14] i40e: report BPF prog id during XDP_QUERY_PROG
Date: Wed, 26 Jul 2017 03:31:20 -0700
Message-ID: <20170726103123.76743-12-jeffrey.t.kirsher@intel.com>
References: <20170726103123.76743-1-jeffrey.t.kirsher@intel.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:64954 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751446AbdGZKft (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Jul 2017 06:35:49 -0400
In-Reply-To: <20170726103123.76743-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>

Fill the XDP prog_id with the id just like we do in other XDP enabled
drivers such as ixgbe. This is needed so that on dump we can retrieve
the attached program based on the id, and dump BPF insns, opcodes, etc
back to user space. Only XDP driver missing this is currently i40e.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: John Fastabend <john.fastabend@gmail.com>
Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 2b115b0c5296..4104944ea367 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -9601,6 +9601,7 @@ static int i40e_xdp(struct net_device *dev,
 		return i40e_xdp_setup(vsi, xdp->prog);
 	case XDP_QUERY_PROG:
 		xdp->prog_attached = i40e_enabled_xdp_vsi(vsi);
+		xdp->prog_id = vsi->xdp_prog ? vsi->xdp_prog->aux->id : 0;
 		return 0;
 	default:
 		return -EINVAL;
-- 
2.13.3
