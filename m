From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next v2 11/13] nfp: mark port state as stale after reconfig
Date: Mon, 22 May 2017 10:59:32 -0700
Message-ID: <20170522175934.27447-12-jakub.kicinski@netronome.com>
References: <20170522175934.27447-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:36473 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760921AbdEVSBM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 14:01:12 -0400
Received: by mail-pf0-f175.google.com with SMTP id m17so89351617pfg.3
        for <netdev@vger.kernel.org>; Mon, 22 May 2017 11:01:11 -0700 (PDT)
In-Reply-To: <20170522175934.27447-1-jakub.kicinski@netronome.com>
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
index 40ba5775ff79..12cbf21df3b9 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -596,6 +596,8 @@ void nfp_net_refresh_port_table(struct nfp_port *port)
 {
 	struct nfp_pf *pf = port->app->pf;
 
+	set_bit(NFP_PORT_CHANGED, &port->flags);
+
 	schedule_work(&pf->port_refresh_work);
 }
 
-- 
2.11.0
