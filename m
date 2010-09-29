From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] arp: remove unnecessary export of arp_broken_ops
Date: Wed, 29 Sep 2010 12:08:02 +0900
Message-ID: <20100929120802.2f642d0d@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57251 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751223Ab0I2DIL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Sep 2010 23:08:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

arp_broken_ops is only used in arp.c

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/include/net/arp.h	2010-09-29 10:36:46.125871462 +0900
+++ b/include/net/arp.h	2010-09-29 10:36:51.195923872 +0900
@@ -26,6 +26,4 @@ extern struct sk_buff *arp_create(int ty
 				  const unsigned char *target_hw);
 extern void arp_xmit(struct sk_buff *skb);
 
-extern const struct neigh_ops arp_broken_ops;
-
 #endif	/* _ARP_H */
--- a/net/ipv4/arp.c	2010-09-29 10:36:46.135874409 +0900
+++ b/net/ipv4/arp.c	2010-09-29 10:37:15.985915408 +0900
@@ -161,7 +161,7 @@ static const struct neigh_ops arp_direct
 	.queue_xmit =		dev_queue_xmit,
 };
 
-const struct neigh_ops arp_broken_ops = {
+static const struct neigh_ops arp_broken_ops = {
 	.family =		AF_INET,
 	.solicit =		arp_solicit,
 	.error_report =		arp_error_report,
@@ -170,7 +170,6 @@ const struct neigh_ops arp_broken_ops = 
 	.hh_output =		dev_queue_xmit,
 	.queue_xmit =		dev_queue_xmit,
 };
-EXPORT_SYMBOL(arp_broken_ops);
 
 struct neigh_table arp_tbl = {
 	.family		= AF_INET,
