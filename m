From: Dan Carpenter <error27@gmail.com>
Subject: [patch] dcbnl: unlock on an error path in dcbnl_cee_fill()
Date: Fri, 8 Jul 2011 10:27:24 +0300
Message-ID: <20110708072724.GW18655@shale.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	John Fastabend <john.r.fastabend@intel.com>,
	Shmulik Ravid <shmulikr@broadcom.com>,
	"open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: Shmulik Ravid <shmulikr@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:64561 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751089Ab1GHH2k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2011 03:28:40 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to release "dcb_lock" which we took on the previous line.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 6a015f2..3cb56af 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -1409,7 +1409,7 @@ static int dcbnl_cee_fill(struct sk_buff *skb, struct net_device *netdev)
 	spin_lock(&dcb_lock);
 	app = nla_nest_start(skb, DCB_ATTR_CEE_APP_TABLE);
 	if (!app)
-		goto nla_put_failure;
+		goto dcb_unlock;
 
 	list_for_each_entry(itr, &dcb_app_list, list) {
 		if (strncmp(itr->name, netdev->name, IFNAMSIZ) == 0) {
