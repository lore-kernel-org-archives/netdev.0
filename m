From: Cong Wang <amwang@redhat.com>
Subject: [Patch net] ipv6,gre: do not leak info to user-space
Date: Fri, 10 May 2013 15:56:37 +0800
Message-ID: <1368172597-19183-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29774 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751519Ab3EJH4r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 May 2013 03:56:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a hole in struct ip6_tnl_parm2, so we have to
zero the struct on stack before copying it to user-space.

Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index d3ddd84..ecd6073 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -1081,6 +1081,7 @@ static int ip6gre_tunnel_ioctl(struct net_device *dev,
 		}
 		if (t == NULL)
 			t = netdev_priv(dev);
+		memset(&p, 0, sizeof(p));
 		ip6gre_tnl_parm_to_user(&p, &t->parms);
 		if (copy_to_user(ifr->ifr_ifru.ifru_data, &p, sizeof(p)))
 			err = -EFAULT;
@@ -1128,6 +1129,7 @@ static int ip6gre_tunnel_ioctl(struct net_device *dev,
 		if (t) {
 			err = 0;
 
+			memset(&p, 0, sizeof(p));
 			ip6gre_tnl_parm_to_user(&p, &t->parms);
 			if (copy_to_user(ifr->ifr_ifru.ifru_data, &p, sizeof(p)))
 				err = -EFAULT;
