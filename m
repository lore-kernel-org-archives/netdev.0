From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 5/9] ipip: TX path for IPIP/UDP Generic UDP
 Encapsulation
Date: Wed, 16 Jul 2014 21:15:06 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1407162055340.29394@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f202.google.com ([209.85.220.202]:48876 "EHLO
	mail-vc0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752894AbaGQEPI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 00:15:08 -0400
Received: by mail-vc0-f202.google.com with SMTP id hq11so154704vcb.5
        for <netdev@vger.kernel.org>; Wed, 16 Jul 2014 21:15:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support for transmitting encapsulation IPIP in UDP.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv4/ipip.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 62eaa00..91a1c89 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -240,6 +240,11 @@ ipip_tunnel_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	int err = 0;
 	struct ip_tunnel_parm p;
 
+	/* Try generic tunnel ioctls first */
+	err = ip_tunnel_gen_ioctl(dev, ifr, cmd);
+	if (err != -ENOIOCTLCMD)
+		return err;
+
 	if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p)))
 		return -EFAULT;
 
@@ -301,7 +306,8 @@ static int ipip_tunnel_init(struct net_device *dev)
 	memcpy(dev->dev_addr, &tunnel->parms.iph.saddr, 4);
 	memcpy(dev->broadcast, &tunnel->parms.iph.daddr, 4);
 
-	tunnel->hlen = 0;
+	tunnel->tun_hlen = 0;
+	tunnel->hlen = tunnel->tun_hlen + tunnel->encap_hlen;
 	tunnel->parms.iph.protocol = IPPROTO_IPIP;
 	return ip_tunnel_init(dev);
 }
-- 
2.0.0.526.g5318336
