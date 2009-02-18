From: Roel Kluin <roel.kluin@gmail.com>
Subject: Re: [PATCH] RDMA/cxgb3: logical-/bit-or confusion?
Date: Wed, 18 Feb 2009 13:38:27 +0100
Message-ID: <499C0143.1080703@gmail.com>
References: <499BD470.4080705@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: swise@opengridcomputing.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.185]:27667 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751773AbZBRMia (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 07:38:30 -0500
Received: by fk-out-0910.google.com with SMTP id f33so1727988fkf.5
        for <netdev@vger.kernel.org>; Wed, 18 Feb 2009 04:38:27 -0800 (PST)
In-Reply-To: <499BD470.4080705@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dropped general@lists.openfabrics.org since it bounces, and I missed one
in my previously sent patch
--------------------------->8-------------8<------------------------------
Logical-/bit-or typo

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/infiniband/hw/cxgb3/iwch_cm.c b/drivers/infiniband/hw/cxgb3/iwch_cm.c
index 44e936e..21c6145 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_cm.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_cm.c
@@ -890,7 +890,7 @@ static void process_mpa_reply(struct iwch_ep *ep, struct sk_buff *skb)
 	 */
 	state_set(&ep->com, FPDU_MODE);
 	ep->mpa_attr.initiator = 1;
-	ep->mpa_attr.crc_enabled = (mpa->flags & MPA_CRC) | crc_enabled ? 1 : 0;
+	ep->mpa_attr.crc_enabled = (mpa->flags & MPA_CRC) || crc_enabled ? 1 : 0;
 	ep->mpa_attr.recv_marker_enabled = markers_enabled;
 	ep->mpa_attr.xmit_marker_enabled = mpa->flags & MPA_MARKERS ? 1 : 0;
 	ep->mpa_attr.version = mpa_rev;
@@ -1013,7 +1013,7 @@ static void process_mpa_request(struct iwch_ep *ep, struct sk_buff *skb)
 	 * start reply message including private data.
 	 */
 	ep->mpa_attr.initiator = 0;
-	ep->mpa_attr.crc_enabled = (mpa->flags & MPA_CRC) | crc_enabled ? 1 : 0;
+	ep->mpa_attr.crc_enabled = (mpa->flags & MPA_CRC) || crc_enabled ? 1 : 0;
 	ep->mpa_attr.recv_marker_enabled = markers_enabled;
 	ep->mpa_attr.xmit_marker_enabled = mpa->flags & MPA_MARKERS ? 1 : 0;
 	ep->mpa_attr.version = mpa_rev;
