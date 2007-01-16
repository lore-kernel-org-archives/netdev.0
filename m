From: Marcus Better <marcus@better.se>
Subject: [PATCH] nl80211: Allocate array of pointers for nla_parse
Date: Tue, 16 Jan 2007 11:13:52 +0100
Message-ID: <200701161113.52523.marcus@better.se>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from iggypop2.siwnet.net ([81.216.65.12]:63681 "EHLO
	iggypop2.siwnet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750954AbXAPKj5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jan 2007 05:39:57 -0500
Received: from localhost (localhost [127.0.0.1])
	by iggypop2.siwnet.net (Postfix) with SMTP id D70C8205867
	for <netdev@vger.kernel.org>; Tue, 16 Jan 2007 11:13:55 +0100 (CET)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The code allocates an array of struct nlattr, but it seems to me that it should allocate an array of pointers.

Signed-off-by: Marcus Better <marcus@better.se>

--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -843,7 +843,7 @@ static int nl80211_initiate_scan(struct sk_buff *skb, struct genl_info *info)
 
 		channels = kmalloc(count * sizeof(struct scan_channel),
 				   GFP_KERNEL);
-		tb = kmalloc((NL80211_ATTR_MAX+1) * sizeof(struct nlattr),
+		tb = kmalloc((NL80211_ATTR_MAX+1) * sizeof(struct nlattr *),
 			     GFP_KERNEL);
 
 		count = 0;
-- 

