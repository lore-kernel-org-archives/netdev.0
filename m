From: Dan Carpenter <error27@gmail.com>
Subject: [patch] caif: fix a couple range checks
Date: Mon, 7 Jun 2010 16:51:58 +0200
Message-ID: <20100607145158.GO5483@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Sjur Braendeland <sjur.brandeland@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:63195 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751004Ab0FGOwL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 10:52:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The extra ! character means that these conditions are always false.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/net/caif/cfveil.c b/net/caif/cfveil.c
index 0fd827f..e04f7d9 100644
--- a/net/caif/cfveil.c
+++ b/net/caif/cfveil.c
@@ -84,7 +84,7 @@ static int cfvei_transmit(struct cflayer *layr, struct cfpkt *pkt)
 		return ret;
 	caif_assert(layr->dn != NULL);
 	caif_assert(layr->dn->transmit != NULL);
-	if (!cfpkt_getlen(pkt) > CAIF_MAX_PAYLOAD_SIZE) {
+	if (cfpkt_getlen(pkt) > CAIF_MAX_PAYLOAD_SIZE) {
 		pr_warning("CAIF: %s(): Packet too large - size=%d\n",
 			   __func__, cfpkt_getlen(pkt));
 		return -EOVERFLOW;
diff --git a/net/caif/cfrfml.c b/net/caif/cfrfml.c
index cd2830f..fd27b17 100644
--- a/net/caif/cfrfml.c
+++ b/net/caif/cfrfml.c
@@ -83,7 +83,7 @@ static int cfrfml_transmit(struct cflayer *layr, struct cfpkt *pkt)
 	if (!cfsrvl_ready(service, &ret))
 		return ret;
 
-	if (!cfpkt_getlen(pkt) > CAIF_MAX_PAYLOAD_SIZE) {
+	if (cfpkt_getlen(pkt) > CAIF_MAX_PAYLOAD_SIZE) {
 		pr_err("CAIF: %s():Packet too large - size=%d\n",
 			__func__, cfpkt_getlen(pkt));
 		return -EOVERFLOW;
