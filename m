From: Dan Carpenter <error27@gmail.com>
Subject: [patch -next] dcb: use nlmsg_free() instead of kfree()
Date: Thu, 23 Jun 2011 08:58:02 +0300
Message-ID: <20110623055802.GN14591@shale.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Shmulik Ravid <shmulikr@broadcom.com>,
	"open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:37152 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752061Ab1FWF6s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2011 01:58:48 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These sk_buff structs were allocated with nlmsg_new() so they should
be freed with nlmsg_free().

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index e954d4c..fc56e85 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -1329,7 +1329,7 @@ int dcbnl_notify(struct net_device *dev, int event, int cmd,
 
 	nlh = nlmsg_put(skb, pid, 0, event, sizeof(*dcb), 0);
 	if (nlh == NULL) {
-		kfree(skb);
+		nlmsg_free(skb);
 		return -EMSGSIZE;
 	}
 
@@ -1434,7 +1434,7 @@ static int dcbnl_ieee_get(struct net_device *netdev, struct nlattr **tb,
 
 	nlh = nlmsg_put(skb, pid, seq, RTM_GETDCB, sizeof(*dcb), flags);
 	if (nlh == NULL) {
-		kfree(skb);
+		nlmsg_free(skb);
 		return -EMSGSIZE;
 	}
 
