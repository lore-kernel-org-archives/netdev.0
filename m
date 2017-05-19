From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 11/13] nfp: mark port state as stale after reconfig
Date: Fri, 19 May 2017 15:01:53 -0700
Message-ID: <20170519220155.27857-12-jakub.kicinski@netronome.com>
References: <20170519220155.27857-1-jakub.kicinski@netronome.com>
Cc: kubakici@wp.pl, oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:35462 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932558AbdESWC3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 18:02:29 -0400
Received: by mail-pf0-f172.google.com with SMTP id n23so45471489pfb.2
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 15:02:29 -0700 (PDT)
In-Reply-To: <20170519220155.27857-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After port configuration is performed mark it as changed. This
will close a window of time between configuration and async
state refresh which runs from a workqueue where old port state
would be reported.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index 9c4ba929cb0a..3ee9a9772110 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -596,6 +596,8 @@ void nfp_net_refresh_port_table(struct nfp_port *port)
 {
 	struct nfp_pf *pf = nfp_app_pf(port->app);
 
+	set_bit(NFP_PORT_CHANGED, &port->flags);
+
 	schedule_work(&pf->port_refresh_work);
 }
 
-- 
2.11.0
