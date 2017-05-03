From: Ross Lagerwall <ross.lagerwall@citrix.com>
Subject: [PATCH RESEND 4.4-only] netlink: Allow direct reclaim for fallback allocation
Date: Wed, 3 May 2017 09:44:19 +0100
Message-ID: <1493801059-2828-1-git-send-email-ross.lagerwall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ross Lagerwall <ross.lagerwall@citrix.com>,
        "David S. Miller" <davem@davemloft.net>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Eric Dumazet <edumazet@google.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: <stable@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:41951 "EHLO SMTP.CITRIX.COM"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751533AbdECIq2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 3 May 2017 04:46:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The backport of d35c99ff77ec ("netlink: do not enter direct reclaim from
netlink_dump()") to the 4.4 branch (first in 4.4.32) mistakenly removed
direct claim from the initial large allocation _and_ the fallback
allocation which means that allocations can spuriously fail.
Fix the issue by adding back the direct reclaim flag to the fallback
allocation.

Fixes: 6d123f1d396b ("netlink: do not enter direct reclaim from netlink_dump()")
Signed-off-by: Ross Lagerwall <ross.lagerwall@citrix.com>
---

Note that this is only for the 4.4 branch as the regression is only in
this branch. Consequently, there is no corresponding upstream commit.

I'm resending this to the linux-stable list since I now understand the
netdev maintainer only handles backports for the last couple of versions
of Linux.

 net/netlink/af_netlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 8e33019..acfb16f 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2107,7 +2107,7 @@ static int netlink_dump(struct sock *sk)
 	if (!skb) {
 		alloc_size = alloc_min_size;
 		skb = netlink_alloc_skb(sk, alloc_size, nlk->portid,
-					(GFP_KERNEL & ~__GFP_DIRECT_RECLAIM));
+					GFP_KERNEL);
 	}
 	if (!skb)
 		goto errout_skb;
-- 
2.7.4
