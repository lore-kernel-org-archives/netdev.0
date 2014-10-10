From: Lubomir Rintel <lkundrak@v3.sk>
Subject: [PATCH] ipv6: notify userspace when we added or changed an ipv6 token
Date: Fri, 10 Oct 2014 16:08:32 +0200
Message-ID: <1412950112-15593-1-git-send-email-lkundrak@v3.sk>
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Lubomir Rintel <lkundrak@v3.sk>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <dborkman@redhat.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NetworkManager might want to know that it changed when the router advertisement
arrives.

Signed-off-by: Lubomir Rintel <lkundrak@v3.sk>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Daniel Borkmann <dborkman@redhat.com>
---
 net/ipv6/addrconf.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 3e118df..3d11390 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4528,6 +4528,7 @@ static int inet6_set_iftoken(struct inet6_dev *idev, struct in6_addr *token)
 	}
 
 	write_unlock_bh(&idev->lock);
+	netdev_state_change(dev);
 	addrconf_verify_rtnl();
 	return 0;
 }
-- 
1.9.3
