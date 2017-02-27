From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/6] netfilter: nft_ct: fix random validation errors for zone set support
Date: Mon, 27 Feb 2017 12:35:37 +0100
Message-ID: <1488195342-2678-2-git-send-email-pablo@netfilter.org>
References: <1488195342-2678-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:47854 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751910AbdB0Lgl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 27 Feb 2017 06:36:41 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id ABBF2E63D
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 12:35:55 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 9AFC4DA845
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 12:35:55 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 40BDEDA801
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 12:35:53 +0100 (CET)
In-Reply-To: <1488195342-2678-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Dan reports:
 net/netfilter/nft_ct.c:549 nft_ct_set_init()
 error: uninitialized symbol 'len'.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Fixes: edee4f1e924582 ("netfilter: nft_ct: add zone id set support")
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_ct.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netfilter/nft_ct.c b/net/netfilter/nft_ct.c
index c6b8022c0e47..bf548a7a71ec 100644
--- a/net/netfilter/nft_ct.c
+++ b/net/netfilter/nft_ct.c
@@ -528,6 +528,7 @@ static int nft_ct_set_init(const struct nft_ctx *ctx,
 		if (!nft_ct_tmpl_alloc_pcpu())
 			return -ENOMEM;
 		nft_ct_pcpu_template_refcnt++;
+		len = sizeof(u16);
 		break;
 #endif
 	default:
-- 
2.1.4
