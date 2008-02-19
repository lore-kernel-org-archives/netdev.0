From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] bonding: simplify code and get rid of warning
Date: Mon, 18 Feb 2008 21:04:26 -0800
Message-ID: <20080218210426.022bbe36@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:52334 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750696AbYBSFEe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Feb 2008 00:04:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Get rid of warning and simplify code that looks up vlan tag.
No need to get tag, then copy it. Also no need for a local status
variable.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
---
Patch against current 2.6.25 version.

--- a/drivers/net/bonding/bond_alb.c	2008-02-18 20:58:53.000000000 -0800
+++ b/drivers/net/bonding/bond_alb.c	2008-02-18 21:01:10.000000000 -0800
@@ -678,12 +678,8 @@ static struct slave *rlb_choose_channel(
 		}
 
 		if (!list_empty(&bond->vlan_list)) {
-			unsigned short vlan_id;
-			int res = vlan_get_tag(skb, &vlan_id);
-			if (!res) {
+			if (!vlan_get_tag(skb, &client_info->vlan_id))
 				client_info->tag = 1;
-				client_info->vlan_id = vlan_id;
-			}
 		}
 
 		if (!client_info->assigned) {
