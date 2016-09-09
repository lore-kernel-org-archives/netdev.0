From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [PATCH 4/8] ipv4: use IS_ENABLED() instead of checking for built-in or module
Date: Fri,  9 Sep 2016 08:43:16 -0400
Message-ID: <1473425000-9782-5-git-send-email-javier@osg.samsung.com>
References: <1473425000-9782-1-git-send-email-javier@osg.samsung.com>
Cc: Javier Martinez Canillas <javier@osg.samsung.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Patrick McHardy <kaber@trash.net>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ec2-52-27-115-49.us-west-2.compute.amazonaws.com ([52.27.115.49]:52584
        "EHLO s-opensource.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754624AbcIIMo2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 08:44:28 -0400
In-Reply-To: <1473425000-9782-1-git-send-email-javier@osg.samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The IS_ENABLED() macro checks if a Kconfig symbol has been enabled either
built-in or as a module, use that macro instead of open coding the same.

Using the macro makes the code more readable by helping abstract away some
of the Kconfig built-in and module enable details.

Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>
---

 net/ipv4/ip_output.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 65569274efb8..b913f5bf0757 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -490,7 +490,7 @@ static void ip_copy_metadata(struct sk_buff *to, struct sk_buff *from)
 	to->tc_index = from->tc_index;
 #endif
 	nf_copy(to, from);
-#if defined(CONFIG_IP_VS) || defined(CONFIG_IP_VS_MODULE)
+#if IS_ENABLED(CONFIG_IP_VS)
 	to->ipvs_property = from->ipvs_property;
 #endif
 	skb_copy_secmark(to, from);
-- 
2.7.4
