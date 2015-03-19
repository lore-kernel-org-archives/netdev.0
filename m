From: Martin Gerbershagen <martin.gerbershagen@nokia.com>
Subject: [PATCH]    net: 8021q: additionally pass SIOCSHWTSTAMP ioctl flag
 to, the real device
Date: Thu, 19 Mar 2015 11:08:36 +0100
Message-ID: <550AA024.8030606@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from demumfd002.nsn-inter.net ([93.183.12.31]:40681 "EHLO
	demumfd002.nsn-inter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751366AbbCSKRy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 06:17:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


   If vlan devices were used, hardware timestamping did not work. The
   problem was that the SIOCSHWTSTAMP ioctl flag was not passed to the real
   device. This is fixed with this patch.

   Signed-off-by: Martin Gerbershagen <martin.gerbershagen@nokia.com>
---
 net/8021q/vlan_dev.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 1f26a1b..91f97b1 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -385,6 +385,7 @@ static int vlan_dev_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
        case SIOCGMIIPHY:
        case SIOCGMIIREG:
        case SIOCSMIIREG:
+       case SIOCSHWTSTAMP:
                if (netif_device_present(real_dev) && ops->ndo_do_ioctl)
                        err = ops->ndo_do_ioctl(real_dev, &ifrr, cmd);
                break;
-- 
1.8.4.5
