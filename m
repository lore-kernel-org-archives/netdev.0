From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 10/10] net: Allow tunnels to use inner checksum
 offloads with outer checksums needed
Date: Fri, 05 Feb 2016 15:28:26 -0800
Message-ID: <20160205232826.18529.69333.stgit@localhost.localdomain>
References: <20160205232109.18529.99816.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: ecree@solarflare.com, tom@herbertland.com, davem@davemloft.net
To: netdev@vger.kernel.org, alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33125 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751393AbcBEX21 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 18:28:27 -0500
Received: by mail-pa0-f46.google.com with SMTP id cy9so41530065pac.0
        for <netdev@vger.kernel.org>; Fri, 05 Feb 2016 15:28:27 -0800 (PST)
In-Reply-To: <20160205232109.18529.99816.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables us to use inner checksum offloads if provided by
hardware with outer checksums computed by software.

It basically reduces encap_hdr_csum to an advisory flag for now, but based
on the fact that SCTP may be getting segmentation support before long I
thought we may want to keep it as it is possible we may need to support
CRC32c and 1's compliment checksum in the same packet at some point in the
future.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 net/core/skbuff.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 88262c82b96a..b0cce744e2a0 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3004,8 +3004,7 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
 	if (unlikely(!proto))
 		return ERR_PTR(-EINVAL);
 
-	csum = !head_skb->encap_hdr_csum &&
-	    !!can_checksum_protocol(features, proto);
+	csum = !!can_checksum_protocol(features, proto);
 
 	headroom = skb_headroom(head_skb);
 	pos = skb_headlen(head_skb);
