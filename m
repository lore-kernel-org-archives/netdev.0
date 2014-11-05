From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] net; ipv[46] - Remove 2 unnecessary NETDEBUG OOM
 messages
Date: Wed, 05 Nov 2014 14:39:21 -0800
Message-ID: <1415227161.6634.24.camel@perches.com>
References: <1415134000.23168.7.camel@perches.com>
	 <20141105.171623.1142237070388305283.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0116.hostedemail.com ([216.40.44.116]:50679 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750834AbaKEWjY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 17:39:24 -0500
In-Reply-To: <20141105.171623.1142237070388305283.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These messages aren't useful as there's a generic dump_stack()
on OOM.

Neaten the comment and if test above the OOM by separating the
assign in if into an allocation then if test.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/ipv4/ip_output.c  |  8 +++-----
 net/ipv6/ip6_output.c | 10 ++++------
 2 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index bc6471d..4a929ad 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -662,12 +662,10 @@ slow_path:
 		if (len < left)	{
 			len &= ~7;
 		}
-		/*
-		 *	Allocate buffer.
-		 */
 
-		if ((skb2 = alloc_skb(len+hlen+ll_rs, GFP_ATOMIC)) == NULL) {
-			NETDEBUG(KERN_INFO "IP: frag: no memory for new fragment!\n");
+		/* Allocate buffer */
+		skb2 = alloc_skb(len + hlen + ll_rs, GFP_ATOMIC);
+		if (!skb2) {
 			err = -ENOMEM;
 			goto fail;
 		}
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 8e950c2..916d2a1 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -747,13 +747,11 @@ slow_path:
 		if (len < left)	{
 			len &= ~7;
 		}
-		/*
-		 *	Allocate buffer.
-		 */
 
-		if ((frag = alloc_skb(len + hlen + sizeof(struct frag_hdr) +
-				      hroom + troom, GFP_ATOMIC)) == NULL) {
-			NETDEBUG(KERN_INFO "IPv6: frag: no memory for new fragment!\n");
+		/* Allocate buffer */
+		frag = alloc_skb(len + hlen + sizeof(struct frag_hdr) +
+				 hroom + troom, GFP_ATOMIC);
+		if (!frag) {
 			IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
 				      IPSTATS_MIB_FRAGFAILS);
 			err = -ENOMEM;
