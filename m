From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/7] ipv4: fib: Send deletion notification with actual FIB alias type
Date: Thu,  9 Feb 2017 10:28:39 +0100
Message-ID: <1486632524-5588-3-git-send-email-jiri@resnulli.us>
References: <1486632524-5588-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com, Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:36299 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752489AbdBIJ2t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 04:28:49 -0500
Received: by mail-wr0-f194.google.com with SMTP id k90so11246877wrc.3
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 01:28:48 -0800 (PST)
In-Reply-To: <1486632524-5588-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When a FIB alias is removed, a notification is sent using the type
passed from user space - can be RTN_UNSPEC - instead of the actual type
of the removed alias. This is problematic for listeners of the FIB
notification chain, as several FIB aliases can exist with matching
parameters, but the type.

Solve this by passing the actual type of the removed FIB alias.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
CC: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/fib_trie.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 5ef4596..b0bfb1c 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1653,8 +1653,8 @@ int fib_table_delete(struct net *net, struct fib_table *tb,
 		return -ESRCH;
 
 	call_fib_entry_notifiers(net, FIB_EVENT_ENTRY_DEL, key, plen,
-				 fa_to_delete->fa_info, tos, cfg->fc_type,
-				 tb->tb_id, 0);
+				 fa_to_delete->fa_info, tos,
+				 fa_to_delete->fa_type, tb->tb_id, 0);
 	rtmsg_fib(RTM_DELROUTE, htonl(key), fa_to_delete, plen, tb->tb_id,
 		  &cfg->fc_nlinfo, 0);
 
-- 
2.7.4
