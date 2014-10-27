From: Lubomir Rintel <lkundrak@v3.sk>
Subject: [PATCH v3] ipv6: notify userspace when we added or changed an ipv6 token
Date: Mon, 27 Oct 2014 17:39:16 +0100
Message-ID: <1414427956-20056-1-git-send-email-lkundrak@v3.sk>
References: <544D8234.5060504@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Lubomir Rintel <lkundrak@v3.sk>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <dborkman@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41559 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752636AbaJ0Qkx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2014 12:40:53 -0400
In-Reply-To: <544D8234.5060504@redhat.com>
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
Changes since v2:
    - inet6_ifinfo_notify() instead of rtmsg_ifinfo()

 net/ipv6/addrconf.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 3e118df..d9269ef 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4528,6 +4528,7 @@ static int inet6_set_iftoken(struct inet6_dev *idev, struct in6_addr *token)
 	}
 
 	write_unlock_bh(&idev->lock);
+	inet6_ifinfo_notify(RTM_NEWLINK, idev);
 	addrconf_verify_rtnl();
 	return 0;
 }
-- 
1.9.3
