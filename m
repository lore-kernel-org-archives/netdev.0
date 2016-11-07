From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH] rtnl: reset calcit fptr in rtnl_unregister()
Date: Mon,  7 Nov 2016 23:22:19 +0100
Message-ID: <1478557339-16039-1-git-send-email-minipli@googlemail.com>
Cc: netdev@vger.kernel.org, Mathias Krause <minipli@googlemail.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Greg Rose <gregory.v.rose@intel.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36021 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752044AbcKGWWd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 17:22:33 -0500
Received: by mail-wm0-f66.google.com with SMTP id c17so18888252wmc.3
        for <netdev@vger.kernel.org>; Mon, 07 Nov 2016 14:22:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To avoid having dangling function pointers left behind, reset calcit in
rtnl_unregister(), too.

This is no issue so far, as only the rtnl core registers a netlink
handler with a calcit hook which won't be unregistered, but may become
one if new code makes use of the calcit hook.

Fixes: c7ac8679bec9 ("rtnetlink: Compute and store minimum ifinfo...")
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Mathias Krause <minipli@googlemail.com>
---
 net/core/rtnetlink.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 189cc78c77eb..d4c601604bf7 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -275,6 +275,7 @@ int rtnl_unregister(int protocol, int msgtype)
 
 	rtnl_msg_handlers[protocol][msgindex].doit = NULL;
 	rtnl_msg_handlers[protocol][msgindex].dumpit = NULL;
+	rtnl_msg_handlers[protocol][msgindex].calcit = NULL;
 
 	return 0;
 }
-- 
1.7.10.4
