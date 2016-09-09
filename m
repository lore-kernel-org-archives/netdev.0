From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [PATCH 7/8] sctp: use IS_ENABLED() instead of checking for built-in or module
Date: Fri,  9 Sep 2016 08:43:19 -0400
Message-ID: <1473425000-9782-8-git-send-email-javier@osg.samsung.com>
References: <1473425000-9782-1-git-send-email-javier@osg.samsung.com>
Cc: Javier Martinez Canillas <javier@osg.samsung.com>,
        netdev@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        linux-sctp@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ec2-52-27-115-49.us-west-2.compute.amazonaws.com ([52.27.115.49]:52608
        "EHLO s-opensource.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755013AbcIIMou (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 08:44:50 -0400
In-Reply-To: <1473425000-9782-1-git-send-email-javier@osg.samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The IS_ENABLED() macro checks if a Kconfig symbol has been enabled either
built-in or as a module, use that macro instead of open coding the same.

Using the macro makes the code more readable by helping abstract away some
of the Kconfig built-in and module enable details.

Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>
---

 net/sctp/auth.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sctp/auth.c b/net/sctp/auth.c
index 912eb1685a5d..f99d4855d3de 100644
--- a/net/sctp/auth.c
+++ b/net/sctp/auth.c
@@ -48,7 +48,7 @@ static struct sctp_hmac sctp_hmac_list[SCTP_AUTH_NUM_HMACS] = {
 		/* id 2 is reserved as well */
 		.hmac_id = SCTP_AUTH_HMAC_ID_RESERVED_2,
 	},
-#if defined (CONFIG_CRYPTO_SHA256) || defined (CONFIG_CRYPTO_SHA256_MODULE)
+#if IS_ENABLED(CONFIG_CRYPTO_SHA256)
 	{
 		.hmac_id = SCTP_AUTH_HMAC_ID_SHA256,
 		.hmac_name = "hmac(sha256)",
-- 
2.7.4
