From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH net-next] ip_tunnel: don't add tunnel twice
Date: Thu, 15 May 2014 13:07:02 +0800
Message-ID: <53744B76.3080101@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: <kaber@trash.net>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([59.151.112.132]:63454 "EHLO
	heian.cn.fujitsu.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751178AbaEOFJa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 01:09:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When using command "ip tunnel add" to add a tunnel, the tunnel will be added twice,
through ip_tunnel_create() and ip_tunnel_update().

Because the second is unnecessary, so we can just break after adding tunnel
through ip_tunnel_create().

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 net/ipv4/ip_tunnel.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index b3f8597..e83af0f 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -755,10 +755,8 @@ int ip_tunnel_ioctl(struct net_device *dev, struct ip_tunnel_parm *p, int cmd)
 
 		if (!t && (cmd == SIOCADDTUNNEL)) {
 			t = ip_tunnel_create(net, itn, p);
-			if (IS_ERR(t)) {
-				err = PTR_ERR(t);
-				break;
-			}
+			err = PTR_ERR_OR_ZERO(t);
+			break;
 		}
 		if (dev != itn->fb_tunnel_dev && cmd == SIOCCHGTUNNEL) {
 			if (t != NULL) {
-- 
1.8.3.1
