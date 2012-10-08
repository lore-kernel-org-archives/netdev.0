From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] vxlan: fix more sparse warnings
Date: Mon, 8 Oct 2012 14:55:30 -0700
Message-ID: <20121008145530.54a56962@nehalam.linuxnetplumber.net>
References: <20121007123635.GB24374@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org
To: Fengguang Wu <fengguang.wu@intel.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60374 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751026Ab2JHV4J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Oct 2012 17:56:09 -0400
In-Reply-To: <20121007123635.GB24374@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a couple harmless sparse warnings reported by Fengguang Wu.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Later patches will fix the other warnings as a side effect of more substantial
changes.

--- a/drivers/net/vxlan.c	2012-10-08 13:41:36.920210233 -0700
+++ b/drivers/net/vxlan.c	2012-10-08 13:44:05.630729809 -0700
@@ -1084,13 +1084,13 @@ static int vxlan_fill_info(struct sk_buf
 	if (nla_put_u32(skb, IFLA_VXLAN_ID, vxlan->vni))
 		goto nla_put_failure;
 
-	if (vxlan->gaddr && nla_put_u32(skb, IFLA_VXLAN_GROUP, vxlan->gaddr))
+	if (vxlan->gaddr && nla_put_be32(skb, IFLA_VXLAN_GROUP, vxlan->gaddr))
 		goto nla_put_failure;
 
 	if (vxlan->link && nla_put_u32(skb, IFLA_VXLAN_LINK, vxlan->link))
 		goto nla_put_failure;
 
-	if (vxlan->saddr && nla_put_u32(skb, IFLA_VXLAN_LOCAL, vxlan->saddr))
+	if (vxlan->saddr && nla_put_be32(skb, IFLA_VXLAN_LOCAL, vxlan->saddr))
 		goto nla_put_failure;
 
 	if (nla_put_u8(skb, IFLA_VXLAN_TTL, vxlan->ttl) ||
