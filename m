From: Ken-ichirou MATSUZAWA <chamaken@gmail.com>
Subject: [RFC PATCH 3/5] netlink: mmap: fix status for not delivered skb
Date: Wed, 22 Jul 2015 22:20:57 +0900
Message-ID: <20150722132057.GD18037@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:36844 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756759AbbGVNVD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 09:21:03 -0400
Received: by pdjr16 with SMTP id r16so141301471pdj.3
        for <netdev@vger.kernel.org>; Wed, 22 Jul 2015 06:21:02 -0700 (PDT)
Received: from gmail.com (softbank220009032004.bbtec.net. [220.9.32.4])
        by smtp.gmail.com with ESMTPSA id wh1sm1125876pab.1.2015.07.22.06.21.01
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jul 2015 06:21:02 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>
---
 net/netlink/af_netlink.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 5632ad0..a6fba4c 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -847,7 +847,7 @@ static void netlink_skb_destructor(struct sk_buff *skb)
 		} else {
 			if (!(NETLINK_CB(skb).flags & NETLINK_SKB_DELIVERED)) {
 				hdr->nm_len = 0;
-				netlink_set_status(hdr, NL_MMAP_STATUS_VALID);
+				netlink_set_status(hdr, NL_MMAP_STATUS_UNUSED);
 			}
 			ring = &nlk_sk(sk)->rx_ring;
 		}
-- 
1.7.10.4


----- End forwarded message -----
