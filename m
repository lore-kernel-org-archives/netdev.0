From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/2] gtp: gtp_check_src_ms_ipv4() always return success
Date: Thu, 15 Dec 2016 22:35:52 +0100
Message-ID: <1481837753-10317-2-git-send-email-pablo@netfilter.org>
References: <1481837753-10317-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org, laforge@gnumonks.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57316 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753369AbcLOVgL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Dec 2016 16:36:11 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id B86747661
        for <netdev@vger.kernel.org>; Thu, 15 Dec 2016 22:36:09 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 9C04EDA849
        for <netdev@vger.kernel.org>; Thu, 15 Dec 2016 22:36:09 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 73818DA853
        for <netdev@vger.kernel.org>; Thu, 15 Dec 2016 22:36:07 +0100 (CET)
In-Reply-To: <1481837753-10317-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lionel Gauthier <Lionel.Gauthier@eurecom.fr>

gtp_check_src_ms_ipv4() did not find the PDP context matching with the
UE IP address because the memory location is not right, but the result
is inverted by the Boolean "not" operator.  So whatever is the PDP
context, any call to this function is successful.

Signed-off-by: Lionel Gauthier <Lionel.Gauthier@eurecom.fr>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 drivers/net/gtp.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 98f10c216521..6031d499f2be 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -158,9 +158,9 @@ static bool gtp_check_src_ms_ipv4(struct sk_buff *skb, struct pdp_ctx *pctx,
 	if (!pskb_may_pull(skb, hdrlen + sizeof(struct iphdr)))
 		return false;
 
-	iph = (struct iphdr *)(skb->data + hdrlen + sizeof(struct iphdr));
+	iph = (struct iphdr *)(skb->data + hdrlen);
 
-	return iph->saddr != pctx->ms_addr_ip4.s_addr;
+	return iph->saddr == pctx->ms_addr_ip4.s_addr;
 }
 
 /* Check if the inner IP source address in this packet is assigned to any
-- 
2.1.4
