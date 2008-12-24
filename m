From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: [PATCH] [IPSEC]: Change the ICV length of sha256 to 128 bits
Date: Tue, 23 Dec 2008 23:02:25 -0700
Message-ID: <20081224060225.GA26084@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([142.179.161.236]:55060 "EHLO
	quartz.edm.orcorp.ca" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750938AbYLXGXM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2008 01:23:12 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The existing setting is 96 bits which does not match the RFCs and is
not negotiable via IKEv2. RFC 4868 says the ICV should be 128 bits,
and IKEv2 uses AUTH_HMAC_SHA2_256_128 = 12 to identify it.

git blame says this setting was made before RFC 4868 was published,
so I'm not sure that it was chosen with any standard in mind.

NOTE: This 'breaks' the user space API, however at least StrongSwan
4.2.9's charon already associates AUTH_HMAC_SHA2_256_128 with
the transform name 'sha256'.

Signed-off-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
---
 net/xfrm/xfrm_algo.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/xfrm/xfrm_algo.c b/net/xfrm/xfrm_algo.c
index 4141376..d136b72 100644
--- a/net/xfrm/xfrm_algo.c
+++ b/net/xfrm/xfrm_algo.c
@@ -187,7 +187,7 @@ static struct xfrm_algo_desc aalg_list[] = {
 
 	.uinfo = {
 		.auth = {
-			.icv_truncbits = 96,
+			.icv_truncbits = 128,
 			.icv_fullbits = 256,
 		}
 	},
-- 
1.5.4.2

