From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 01/15] nfp: output control messages to trace_devlink_hwmsg()
Date: Sun,  8 Oct 2017 21:04:03 -0700
Message-ID: <20171009040417.22172-2-jakub.kicinski@netronome.com>
References: <20171009040417.22172-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:54922 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751550AbdJIEFs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 00:05:48 -0400
Received: by mail-pf0-f169.google.com with SMTP id m28so7595065pfi.11
        for <netdev@vger.kernel.org>; Sun, 08 Oct 2017 21:05:48 -0700 (PDT)
In-Reply-To: <20171009040417.22172-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use standard devlink trace point to allow tracing of control
messages.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_app.h | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_app.h b/drivers/net/ethernet/netronome/nfp/nfp_app.h
index af640b5c2108..857bb33020ba 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_app.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_app.h
@@ -36,6 +36,8 @@
 
 #include <net/devlink.h>
 
+#include <trace/events/devlink.h>
+
 #include "nfp_net_repr.h"
 
 struct bpf_prog;
@@ -271,11 +273,17 @@ static inline int nfp_app_xdp_offload(struct nfp_app *app, struct nfp_net *nn,
 
 static inline bool nfp_app_ctrl_tx(struct nfp_app *app, struct sk_buff *skb)
 {
+	trace_devlink_hwmsg(priv_to_devlink(app->pf), false, 0,
+			    skb->data, skb->len);
+
 	return nfp_ctrl_tx(app->ctrl, skb);
 }
 
 static inline void nfp_app_ctrl_rx(struct nfp_app *app, struct sk_buff *skb)
 {
+	trace_devlink_hwmsg(priv_to_devlink(app->pf), true, 0,
+			    skb->data, skb->len);
+
 	app->type->ctrl_msg_rx(app, skb);
 }
 
-- 
2.14.1
