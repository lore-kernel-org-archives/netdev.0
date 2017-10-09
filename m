From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 02/15] nfp: bpf: lift the single-port limitation
Date: Sun,  8 Oct 2017 21:04:04 -0700
Message-ID: <20171009040417.22172-3-jakub.kicinski@netronome.com>
References: <20171009040417.22172-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:52056 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751387AbdJIEFt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 00:05:49 -0400
Received: by mail-pf0-f178.google.com with SMTP id n14so10631611pfh.8
        for <netdev@vger.kernel.org>; Sun, 08 Oct 2017 21:05:49 -0700 (PDT)
In-Reply-To: <20171009040417.22172-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Limiting the eBPF offload to a single port was a workaround
required for the PoC application FW which has not been
released externally.  It's not necessary any more.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/bpf/main.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/bpf/main.c b/drivers/net/ethernet/netronome/nfp/bpf/main.c
index be2cf10a2cd7..074726980994 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/main.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/main.c
@@ -89,14 +89,6 @@ nfp_bpf_vnic_alloc(struct nfp_app *app, struct nfp_net *nn, unsigned int id)
 	struct nfp_net_bpf_priv *priv;
 	int ret;
 
-	/* Limit to single port, otherwise it's just a NIC */
-	if (id > 0) {
-		nfp_warn(app->cpp,
-			 "BPF NIC doesn't support more than one port right now\n");
-		nn->port = nfp_port_alloc(app, NFP_PORT_INVALID, nn->dp.netdev);
-		return PTR_ERR_OR_ZERO(nn->port);
-	}
-
 	priv = kmalloc(sizeof(*priv), GFP_KERNEL);
 	if (!priv)
 		return -ENOMEM;
-- 
2.14.1
