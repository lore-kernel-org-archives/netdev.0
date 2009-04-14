From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] netsched: Allow meta match on vlan tag on receive
Date: Mon, 13 Apr 2009 17:30:08 -0700
Message-ID: <20090413173008.3278a54c@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42736 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751319AbZDNAaP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Apr 2009 20:30:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When vlan acceleration is used on receive, the vlan tag is maintained
outside of the skb data. The existing vlan tag match only works on TX
path because it uses vlan_get_tag which tests for VLAN_HW_TX_ACCEL.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/sched/em_meta.c	2009-04-08 08:45:13.000000000 -0700
+++ b/net/sched/em_meta.c	2009-04-09 09:26:32.397494374 -0700
@@ -176,8 +176,10 @@ META_COLLECTOR(var_dev)
 
 META_COLLECTOR(int_vlan_tag)
 {
-	unsigned short uninitialized_var(tag);
-	if (vlan_get_tag(skb, &tag) < 0)
+	unsigned short tag;
+
+	tag = vlan_tx_tag_get(skb);
+	if (!tag && __vlan_get_tag(skb, &tag))
 		*err = -1;
 	else
 		dst->value = tag;
