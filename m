From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH net-next] 6lowpan: reassembly: fix access of ctl table entry
Date: Sun,  9 Mar 2014 09:51:40 +0100
Message-ID: <1394355100-27824-1-git-send-email-alex.aring@gmail.com>
Cc: dbaryshkov@gmail.com, davem@davemloft.net,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:41080 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751277AbaCIIjU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Mar 2014 04:39:20 -0400
Received: by mail-ea0-f174.google.com with SMTP id f15so3054625eak.5
        for <netdev@vger.kernel.org>; Sun, 09 Mar 2014 00:39:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Correct offset is 3 of the 6lowpanfrag_max_datagram_size value in proc
entry ctl table and not 2.

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
---
 net/ieee802154/reassembly.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ieee802154/reassembly.c b/net/ieee802154/reassembly.c
index bf06492..f4ac957 100644
--- a/net/ieee802154/reassembly.c
+++ b/net/ieee802154/reassembly.c
@@ -441,7 +441,7 @@ static int __net_init lowpan_frags_ns_sysctl_register(struct net *net)
 		table[0].data = &net->ieee802154_lowpan.frags.high_thresh;
 		table[1].data = &net->ieee802154_lowpan.frags.low_thresh;
 		table[2].data = &net->ieee802154_lowpan.frags.timeout;
-		table[2].data = &net->ieee802154_lowpan.max_dsize;
+		table[3].data = &net->ieee802154_lowpan.max_dsize;
 
 		/* Don't export sysctls to unprivileged users */
 		if (net->user_ns != &init_user_ns)
-- 
1.9.0
