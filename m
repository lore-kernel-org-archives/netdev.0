From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] ipv6 addrconf: revert /proc/net/if_inet6 ifa_flag format
Date: Tue, 10 Dec 2013 13:56:29 +0100
Message-ID: <1386680189-7852-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, thaller@redhat.com,
	alex.aring@gmail.com, florent.fourcot@enst-bretagne.fr
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f170.google.com ([209.85.215.170]:59586 "EHLO
	mail-ea0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751823Ab3LJM4d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 07:56:33 -0500
Received: by mail-ea0-f170.google.com with SMTP id k10so2244774eaj.29
        for <netdev@vger.kernel.org>; Tue, 10 Dec 2013 04:56:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Turned out that applications like ifconfig do not handle the change.
So revert ifa_flag format back to 2-letter hex value.

Introduced by:
commit 479840ffdbe4242e8a25349218c8e0859223aa35
    "ipv6 addrconf: extend ifa_flags to u32"

Reported-by: Alexander Aring <alex.aring@gmail.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/ipv6/addrconf.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index be4dbbd..3c3425e 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3367,12 +3367,12 @@ static void if6_seq_stop(struct seq_file *seq, void *v)
 static int if6_seq_show(struct seq_file *seq, void *v)
 {
 	struct inet6_ifaddr *ifp = (struct inet6_ifaddr *)v;
-	seq_printf(seq, "%pi6 %02x %02x %02x %03x %8s\n",
+	seq_printf(seq, "%pi6 %02x %02x %02x %02x %8s\n",
 		   &ifp->addr,
 		   ifp->idev->dev->ifindex,
 		   ifp->prefix_len,
 		   ifp->scope,
-		   ifp->flags,
+		   (u8) ifp->flags,
 		   ifp->idev->dev->name);
 	return 0;
 }
-- 
1.8.3.1
