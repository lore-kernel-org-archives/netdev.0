From: Dan Carpenter <error27@gmail.com>
Subject: [patch -next] caif: precedence bug
Date: Thu, 22 Jul 2010 13:11:31 +0200
Message-ID: <20100722111131.GB17585@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Sjur Braendeland <sjur.brandeland@stericsson.com>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: SjurBraendeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:61902 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759246Ab0GVLMQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 07:12:16 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Negate has precedence over comparison so the original assert only
checked that "rfml->fragment_size" was larger than 1 or 0.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/net/caif/cfrfml.c b/net/caif/cfrfml.c
index 4b04d25..eb16020 100644
--- a/net/caif/cfrfml.c
+++ b/net/caif/cfrfml.c
@@ -193,7 +193,7 @@ out:
 
 static int cfrfml_transmit_segment(struct cfrfml *rfml, struct cfpkt *pkt)
 {
-	caif_assert(!cfpkt_getlen(pkt) < rfml->fragment_size);
+	caif_assert(cfpkt_getlen(pkt) >= rfml->fragment_size);
 
 	/* Add info for MUX-layer to route the packet out. */
 	cfpkt_info(pkt)->channel_id = rfml->serv.layer.id;
