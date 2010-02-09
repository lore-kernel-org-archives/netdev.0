From: jamal <hadi@cyberus.ca>
Subject: [PATCH] xfrm: validate attributes
Date: Tue, 09 Feb 2010 08:59:38 -0500
Message-ID: <1265723978.3688.82.camel@bigi>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-RCW07ZrwQ2NcAOKZtti5"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.27]:55126 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754239Ab0BIN7m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2010 08:59:42 -0500
Received: by qw-out-2122.google.com with SMTP id 9so857423qwb.37
        for <netdev@vger.kernel.org>; Tue, 09 Feb 2010 05:59:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-RCW07ZrwQ2NcAOKZtti5
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


make sure all XFRMAs go through validation in case wrong
content is passed

cheers,
jamal

--=-RCW07ZrwQ2NcAOKZtti5
Content-Disposition: attachment; filename="xfrma-vald"
Content-Type: text/plain; name="xfrma-vald"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

commit 979fef2abd38392e28c851215c59d1128fe0f776
Author: Jamal Hadi Salim <hadi@cyberus.ca>
Date:   Tue Feb 9 08:47:57 2010 -0500

    xfrm: validate attributes
    
    Some XFRM attributes were not going through basic validation.
    
    Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index d5a7129..943c871 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2054,6 +2054,10 @@ static const int xfrm_msg_min[XFRM_NR_MSGTYPES] = {
 #undef XMSGSIZE
 
 static const struct nla_policy xfrma_policy[XFRMA_MAX+1] = {
+	[XFRMA_SA]		= { .len = sizeof(struct xfrm_usersa_info)},
+	[XFRMA_POLICY]		= { .len = sizeof(struct xfrm_userpolicy_info)},
+	[XFRMA_LASTUSED]	= { .type = NLA_U64},
+	[XFRMA_ALG_AUTH_TRUNC]	= { .len = sizeof(struct xfrm_algo_auth)},
 	[XFRMA_ALG_AEAD]	= { .len = sizeof(struct xfrm_algo_aead) },
 	[XFRMA_ALG_AUTH]	= { .len = sizeof(struct xfrm_algo) },
 	[XFRMA_ALG_CRYPT]	= { .len = sizeof(struct xfrm_algo) },

--=-RCW07ZrwQ2NcAOKZtti5--

