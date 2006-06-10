From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] bnx2: endian fixes
Date: Sat, 10 Jun 2006 15:52:51 +0400
Message-ID: <20060610115250.GA7268@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:40548 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1751492AbWFJLwd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Jun 2006 07:52:33 -0400
Received: by nf-out-0910.google.com with SMTP id d4so641249nfe
        for <netdev@vger.kernel.org>; Sat, 10 Jun 2006 04:52:32 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 drivers/net/bnx2.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -1820,7 +1820,7 @@ reuse_rx:
 		skb->protocol = eth_type_trans(skb, bp->dev);
 
 		if ((len > (bp->dev->mtu + ETH_HLEN)) &&
-			(htons(skb->protocol) != 0x8100)) {
+			(ntohs(skb->protocol) != 0x8100)) {
 
 			dev_kfree_skb_irq(skb);
 			goto next_rx;
@@ -4310,7 +4310,7 @@ bnx2_start_xmit(struct sk_buff *skb, str
 		ip_tcp_len = (skb->nh.iph->ihl << 2) + sizeof(struct tcphdr);
 
 		skb->nh.iph->check = 0;
-		skb->nh.iph->tot_len = ntohs(mss + ip_tcp_len + tcp_opt_len);
+		skb->nh.iph->tot_len = htons(mss + ip_tcp_len + tcp_opt_len);
 		skb->h.th->check =
 			~csum_tcpudp_magic(skb->nh.iph->saddr,
 					    skb->nh.iph->daddr,

