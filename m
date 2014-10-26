From: Lubomir Rintel <lkundrak@v3.sk>
Subject: [PATCH v2] ipv6: notify userspace when we added or changed an ipv6 token
Date: Sun, 26 Oct 2014 23:41:23 +0100
Message-ID: <1414363283-31410-1-git-send-email-lkundrak@v3.sk>
References: <1412950112-15593-1-git-send-email-lkundrak@v3.sk>
Cc: "David S. Miller" <davem@davemloft.net>,
	Lubomir Rintel <lkundrak@v3.sk>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <dborkman@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45400 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751605AbaJZWlu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Oct 2014 18:41:50 -0400
In-Reply-To: <1412950112-15593-1-git-send-email-lkundrak@v3.sk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NetworkManager might want to know that it changed when the router advertisement
arrives.

Signed-off-by: Lubomir Rintel <lkundrak@v3.sk>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Daniel Borkmann <dborkman@redhat.com>
---
Changes since v1:
    - Do not call device notifier chain with netdev_state_change()

 net/ipv6/addrconf.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 3e118df..f6f92f5 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4528,6 +4528,7 @@ static int inet6_set_iftoken(struct inet6_dev *idev, struct in6_addr *token)
 	}
 
 	write_unlock_bh(&idev->lock);
+	rtmsg_ifinfo(RTM_NEWLINK, dev, 0, GFP_KERNEL);
 	addrconf_verify_rtnl();
 	return 0;
 }
-- 
1.9.3
