From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net 2/2] ila: Fix memory leak of lwt dst cache on module unload
Date: Wed, 18 Jan 2017 15:32:03 +0000
Message-ID: <1484753523-26230-3-git-send-email-rshearma@brocade.com>
References: <1484753523-26230-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Tom Herbert <tom@herbertland.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        Robert Shearman <rshearma@brocade.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:51470 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752164AbdARPdz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 10:33:55 -0500
In-Reply-To: <1484753523-26230-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If routes with lwt state are present when the ila module is unloaded
and then subsequently deleted, the dst cache entry in the state will
be leaked.

Fix this by specifying the owning module in the lwt ops to allow lwt
to take a reference for each route and to keep the module around until
the last ila route is deleted.

Fixes: 79ff2fc31e0f ("ila: Cache a route to translated address")
Signed-off-by: Robert Shearman <rshearma@brocade.com>
---
 net/ipv6/ila/ila_lwt.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/ila/ila_lwt.c b/net/ipv6/ila/ila_lwt.c
index a7bc54ab46e2..13b5e85fe0d5 100644
--- a/net/ipv6/ila/ila_lwt.c
+++ b/net/ipv6/ila/ila_lwt.c
@@ -238,6 +238,7 @@ static const struct lwtunnel_encap_ops ila_encap_ops = {
 	.fill_encap = ila_fill_encap_info,
 	.get_encap_size = ila_encap_nlsize,
 	.cmp_encap = ila_encap_cmp,
+	.owner = THIS_MODULE,
 };
 
 int ila_lwt_init(void)
-- 
2.1.4
