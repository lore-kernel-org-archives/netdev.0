From: Tom Herbert <therbert@google.com>
Subject: [PATCH RFC 6/7] net: TX path for IPIP/UDP Generic UDP
 Encpasulation
Date: Thu, 2 Jan 2014 14:19:03 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1401021414490.32160@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: hkchu@google.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f73.google.com ([209.85.219.73]:33730 "EHLO
	mail-oa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751136AbaABWTE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 17:19:04 -0500
Received: by mail-oa0-f73.google.com with SMTP id i4so3335434oah.2
        for <netdev@vger.kernel.org>; Thu, 02 Jan 2014 14:19:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support for transmitting encapsulation IPIP in UDP.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv4/ipip.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index fe3e9f7..2e997d3 100644
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
1.8.5.1
