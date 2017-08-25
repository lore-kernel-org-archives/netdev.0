From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 2/2] nfp: add basic SR-IOV ndo functions to representors
Date: Thu, 24 Aug 2017 21:31:50 -0700
Message-ID: <20170825043150.375-3-jakub.kicinski@netronome.com>
References: <20170825043150.375-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>,
        Dirk van der Merwe <dirk.vandermerwe@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:38764 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751581AbdHYEci (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 00:32:38 -0400
Received: by mail-pg0-f49.google.com with SMTP id b8so8495327pgn.5
        for <netdev@vger.kernel.org>; Thu, 24 Aug 2017 21:32:38 -0700 (PDT)
In-Reply-To: <20170825043150.375-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <simon.horman@netronome.com>

Add basic ndo_set/get_vf to support SR-IOV on all types
of port representors.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
Signed-off-by: Dirk van der Merwe <dirk.vandermerwe@netronome.com>
Reviewed-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_repr.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c b/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c
index 0f9878d1bf40..d540a9dc77b3 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c
@@ -43,6 +43,7 @@
 #include "nfp_main.h"
 #include "nfp_net_ctrl.h"
 #include "nfp_net_repr.h"
+#include "nfp_net_sriov.h"
 #include "nfp_port.h"
 
 static void
@@ -247,6 +248,11 @@ const struct net_device_ops nfp_repr_netdev_ops = {
 	.ndo_get_offload_stats	= nfp_repr_get_offload_stats,
 	.ndo_get_phys_port_name	= nfp_port_get_phys_port_name,
 	.ndo_setup_tc		= nfp_port_setup_tc,
+	.ndo_set_vf_mac		= nfp_app_set_vf_mac,
+	.ndo_set_vf_vlan	= nfp_app_set_vf_vlan,
+	.ndo_set_vf_spoofchk	= nfp_app_set_vf_spoofchk,
+	.ndo_get_vf_config	= nfp_app_get_vf_config,
+	.ndo_set_vf_link_state	= nfp_app_set_vf_link_state,
 };
 
 static void nfp_repr_clean(struct nfp_repr *repr)
-- 
2.11.0
