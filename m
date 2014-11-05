From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] net: esp: Convert NETDEBUG to pr_info
Date: Wed, 05 Nov 2014 15:36:08 -0800
Message-ID: <1415230568.6634.36.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0153.hostedemail.com ([216.40.44.153]:53872 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750966AbaKEXgM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 18:36:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 64ce207306de ("[NET]: Make NETDEBUG pure printk wrappers")
originally had these NETDEBUG printks as always emitting.

Commit a2a316fd068c ("[NET]: Replace CONFIG_NET_DEBUG with sysctl")
added a net_msg_warn sysctl to these NETDEBUG uses.

Convert these NETDEBUG uses to normal pr_info calls.

This changes the output prefix from "ESP: " to include
"IPSec: " for the ipv4 case and "IPv6: " for the ipv6 case.

These output lines are now like the other messages in the files.

Other miscellanea:

Neaten the arithmetic spacing to be consistent with other
arithmetic spacing in the files.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/ipv4/esp4.c | 10 +++++-----
 net/ipv6/esp6.c | 10 +++++-----
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index d2bf02e..60173d4 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -603,12 +603,12 @@ static int esp_init_authenc(struct xfrm_state *x)
 		BUG_ON(!aalg_desc);
 
 		err = -EINVAL;
-		if (aalg_desc->uinfo.auth.icv_fullbits/8 !=
+		if (aalg_desc->uinfo.auth.icv_fullbits / 8 !=
 		    crypto_aead_authsize(aead)) {
-			NETDEBUG(KERN_INFO "ESP: %s digestsize %u != %hu\n",
-				 x->aalg->alg_name,
-				 crypto_aead_authsize(aead),
-				 aalg_desc->uinfo.auth.icv_fullbits/8);
+			pr_info("ESP: %s digestsize %u != %hu\n",
+				x->aalg->alg_name,
+				crypto_aead_authsize(aead),
+				aalg_desc->uinfo.auth.icv_fullbits / 8);
 			goto free_key;
 		}
 
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 83fc3a3..d21d7b2 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -544,12 +544,12 @@ static int esp_init_authenc(struct xfrm_state *x)
 		BUG_ON(!aalg_desc);
 
 		err = -EINVAL;
-		if (aalg_desc->uinfo.auth.icv_fullbits/8 !=
+		if (aalg_desc->uinfo.auth.icv_fullbits / 8 !=
 		    crypto_aead_authsize(aead)) {
-			NETDEBUG(KERN_INFO "ESP: %s digestsize %u != %hu\n",
-				 x->aalg->alg_name,
-				 crypto_aead_authsize(aead),
-				 aalg_desc->uinfo.auth.icv_fullbits/8);
+			pr_info("ESP: %s digestsize %u != %hu\n",
+				x->aalg->alg_name,
+				crypto_aead_authsize(aead),
+				aalg_desc->uinfo.auth.icv_fullbits / 8);
 			goto free_key;
 		}
 
