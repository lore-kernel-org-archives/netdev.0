From: Joe Eykholt <jre@nuovasystems.com>
Subject: [PATCH 3/3] bonding: Allow receive on active slaves.
Date: Sun, 04 May 2008 20:00:34 -0700
Message-ID: <20080505030034.18871.79989.stgit@feynman.nuovasystems.com>
References: <20080505025801.18871.89526.stgit@feynman.nuovasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vpn.nuovasystems.com ([67.91.200.194]:7776 "EHLO
	feynman.nuovasystems.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751632AbYEEDbd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2008 23:31:33 -0400
Received: from feynman.nuovasystems.com (feynman.nuovasystems.com [127.0.0.1])
	by feynman.nuovasystems.com (8.14.2/8.14.2) with ESMTP id m4530Y7d018949
	for <netdev@vger.kernel.org>; Sun, 4 May 2008 20:00:34 -0700
In-Reply-To: <20080505025801.18871.89526.stgit@feynman.nuovasystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bonding: Allow receive on active slaves.

If a packet_type specifies an active slave and not just any interface,
allow it to receive frames that came in on that interface.

Signed-off-by: Joe Eykholt <jre@nuovasystems.com>
---
 net/core/dev.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)


diff --git a/net/core/dev.c b/net/core/dev.c
index ac5d8ac..eb8cd0f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2048,7 +2048,8 @@ int netif_receive_skb(struct sk_buff *skb)
 #endif
 
 	list_for_each_entry_rcu(ptype, &ptype_all, list) {
-		if (ptype->dev == null_or_orig || ptype->dev == skb->dev) {
+		if (ptype->dev == null_or_orig || ptype->dev == skb->dev ||
+		    ptype->dev == orig_dev) {
 			if (pt_prev)
 				ret = deliver_skb(skb, pt_prev, orig_dev);
 			pt_prev = ptype;
@@ -2073,7 +2074,8 @@ ncls:
 	list_for_each_entry_rcu(ptype,
 			&ptype_base[ntohs(type) & PTYPE_HASH_MASK], list) {
 		if (ptype->type == type &&
-		    (ptype->dev == null_or_orig || ptype->dev == skb->dev)) {
+		    (ptype->dev == null_or_orig || ptype->dev == skb->dev ||
+		     ptype->dev == orig_dev)) {
 			if (pt_prev)
 				ret = deliver_skb(skb, pt_prev, orig_dev);
 			pt_prev = ptype;


