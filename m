From: Ken-ichirou MATSUZAWA <chamaken@gmail.com>
Subject: [PATCH net] netlink: mmap: fix status setting in skb destructor
Date: Thu, 20 Aug 2015 16:07:33 +0900
Message-ID: <20150820070733.GA3711@gmail.com>
References: <20150722131730.GA18037@gmail.com>
 <20150812082824.GA13385@gmail.com>
 <20150812.163819.620222685130362816.davem@davemloft.net>
 <20150814085807.GA30443@gmail.com>
 <55CDBC84.8020605@iogearbox.net>
 <55CDC51D.1060204@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>, fw@strlen.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33943 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751245AbbHTHHi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 03:07:38 -0400
Received: by pacrn3 with SMTP id rn3so782112pac.1
        for <netdev@vger.kernel.org>; Thu, 20 Aug 2015 00:07:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <55CDC51D.1060204@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I don't know the intension of setting VALID status in the skb
destructor. But I think it need to be set UNUSED status in case of
error then release skb, or rx ring might be filled with RESERVED
frames.

Signed-off-by: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>
---
 net/netlink/af_netlink.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index e6134f4..85ccd8b 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -864,7 +864,7 @@ static void netlink_skb_destructor(struct sk_buff *skb)
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
