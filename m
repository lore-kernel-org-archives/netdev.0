From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 5/5] net/core: Allow receive on active slaves.
Date: Wed,  2 Jul 2008 18:22:02 -0700
Message-ID: <1215048128335-git-send-email-fubar@us.ibm.com>
References: <12150481222323-git-send-email-fubar@us.ibm.com>
 <12150481241992-git-send-email-fubar@us.ibm.com>
 <1215048125108-git-send-email-fubar@us.ibm.com>
 <12150481262025-git-send-email-fubar@us.ibm.com>
 <1215048127619-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>,
	Joe Eykholt <jre@nuovasystems.com>,
	Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:33402 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752025AbYGCBWL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2008 21:22:11 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m631MAmh022939
	for <netdev@vger.kernel.org>; Wed, 2 Jul 2008 21:22:10 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m631MAXq179150
	for <netdev@vger.kernel.org>; Wed, 2 Jul 2008 21:22:10 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m631M9am004245
	for <netdev@vger.kernel.org>; Wed, 2 Jul 2008 21:22:10 -0400
In-Reply-To: <1215048127619-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Eykholt <jre@nuovasystems.com>

If a packet_type specifies an active slave to bonding and not just any
interface, allow it to receive frames that came in on that interface.

Signed-off-by: Joe Eykholt <jre@nuovasystems.com>
Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 net/core/dev.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index a949664..d68f662 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2104,7 +2104,8 @@ int netif_receive_skb(struct sk_buff *skb)
 #endif
 
 	list_for_each_entry_rcu(ptype, &ptype_all, list) {
-		if (ptype->dev == null_or_orig || ptype->dev == skb->dev) {
+		if (ptype->dev == null_or_orig || ptype->dev == skb->dev ||
+		    ptype->dev == orig_dev) {
 			if (pt_prev)
 				ret = deliver_skb(skb, pt_prev, orig_dev);
 			pt_prev = ptype;
@@ -2129,7 +2130,8 @@ ncls:
 	list_for_each_entry_rcu(ptype,
 			&ptype_base[ntohs(type) & PTYPE_HASH_MASK], list) {
 		if (ptype->type == type &&
-		    (ptype->dev == null_or_orig || ptype->dev == skb->dev)) {
+		    (ptype->dev == null_or_orig || ptype->dev == skb->dev ||
+		     ptype->dev == orig_dev)) {
 			if (pt_prev)
 				ret = deliver_skb(skb, pt_prev, orig_dev);
 			pt_prev = ptype;
-- 
1.5.2.4

