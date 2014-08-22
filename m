From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 net-next 6/6] gre: When GRE csum is present count as encap
 layer wrt csum
Date: Fri, 22 Aug 2014 13:34:52 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1408221316450.1827@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f201.google.com ([209.85.214.201]:57420 "EHLO
	mail-ob0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751234AbaHVUex (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 16:34:53 -0400
Received: by mail-ob0-f201.google.com with SMTP id va2so1720908obc.4
        for <netdev@vger.kernel.org>; Fri, 22 Aug 2014 13:34:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In GRE demux if the GRE checksum pop rcv encapsulation so that any
encapsulated checksums are treated as tunnel checksums.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv4/gre_demux.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/gre_demux.c b/net/ipv4/gre_demux.c
index 0485bf7..7c1a8ff 100644
--- a/net/ipv4/gre_demux.c
+++ b/net/ipv4/gre_demux.c
@@ -125,6 +125,7 @@ static int parse_gre_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
 			*csum_err = true;
 			return -EINVAL;
 		}
+		skb_pop_rcv_encapsulation(skb);
 		options++;
 	}
 
-- 
2.1.0.rc2.206.gedb03e5
