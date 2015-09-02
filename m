From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] ipv6: fix exthdrs offload registration in out_rt path
Date: Thu,  3 Sep 2015 00:29:07 +0200
Message-ID: <fcd965e793be00159b46bbc672dd742e2f2615aa.1441230755.git.daniel@iogearbox.net>
Cc: vyasevic@redhat.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48438 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750891AbbIBW3N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 18:29:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We previously register IPPROTO_ROUTING offload under inet6_add_offload(),
but in error path, we try to unregister it with inet_del_offload(). This
doesn't seem correct, it should actually be inet6_del_offload(), also
ipv6_exthdrs_offload_exit() from that commit seems rather incorrect (it
also uses rthdr_offload twice), but it got removed entirely later on.

Fixes: 3336288a9fea ("ipv6: Switch to using new offload infrastructure.")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 (Found during code review.)

 net/ipv6/exthdrs_offload.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/exthdrs_offload.c b/net/ipv6/exthdrs_offload.c
index 447a7fb..f5e2ba1 100644
--- a/net/ipv6/exthdrs_offload.c
+++ b/net/ipv6/exthdrs_offload.c
@@ -36,6 +36,6 @@ out:
 	return ret;
 
 out_rt:
-	inet_del_offload(&rthdr_offload, IPPROTO_ROUTING);
+	inet6_del_offload(&rthdr_offload, IPPROTO_ROUTING);
 	goto out;
 }
-- 
1.9.3
