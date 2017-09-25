Return-Path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f176.google.com ([209.85.128.176]:55180 "EHLO
        mail-wr0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933358AbdIYKYB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 06:24:01 -0400
Received: by mail-wr0-f176.google.com with SMTP id g29so6871051wrg.11
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 03:24:00 -0700 (PDT)
From: Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        John Hurley <john.hurley@netronome.com>,
        Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next 1/7] nfp: add helper to get flower cmsg length
Date: Mon, 25 Sep 2017 12:23:35 +0200
Message-Id: <1506335021-32024-2-git-send-email-simon.horman@netronome.com>
In-Reply-To: <1506335021-32024-1-git-send-email-simon.horman@netronome.com>
References: <1506335021-32024-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Hurley <john.hurley@netronome.com>

Add a helper function that returns the length of the cmsg data when given
the cmsg skb

Signed-off-by: John Hurley <john.hurley@netronome.com>
Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/flower/cmsg.h     | 5 +++++
 drivers/net/ethernet/netronome/nfp/flower/metadata.c | 2 +-
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/netronome/nfp/flower/cmsg.h b/drivers/net/ethernet/netronome/nfp/flower/cmsg.h
index a2ec60344236..7a5ccf0cc7c2 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/cmsg.h
+++ b/drivers/net/ethernet/netronome/nfp/flower/cmsg.h
@@ -323,6 +323,11 @@ static inline void *nfp_flower_cmsg_get_data(struct sk_buff *skb)
 	return (unsigned char *)skb->data + NFP_FLOWER_CMSG_HLEN;
 }
 
+static inline int nfp_flower_cmsg_get_data_len(struct sk_buff *skb)
+{
+	return skb->len - NFP_FLOWER_CMSG_HLEN;
+}
+
 struct sk_buff *
 nfp_flower_cmsg_mac_repr_start(struct nfp_app *app, unsigned int num_ports);
 void
diff --git a/drivers/net/ethernet/netronome/nfp/flower/metadata.c b/drivers/net/ethernet/netronome/nfp/flower/metadata.c
index 3226ddc55f99..193520ef23f0 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/metadata.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/metadata.c
@@ -140,7 +140,7 @@ nfp_flower_update_stats(struct nfp_app *app, struct nfp_fl_stats_frame *stats)
 
 void nfp_flower_rx_flow_stats(struct nfp_app *app, struct sk_buff *skb)
 {
-	unsigned int msg_len = skb->len - NFP_FLOWER_CMSG_HLEN;
+	unsigned int msg_len = nfp_flower_cmsg_get_data_len(skb);
 	struct nfp_fl_stats_frame *stats_frame;
 	unsigned char *msg;
 	int i;
-- 
2.1.4
