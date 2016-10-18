From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] vlan: Remove unnecessary comparison of unsigned against 0
Date: Tue, 18 Oct 2016 08:44:17 +0200
Message-ID: <20161018064417.26379-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:50288 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757791AbcJRGoU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Oct 2016 02:44:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

args.u.name_type is of type unsigned int and is always >= 0.

This fixes the following GCC warning:

  net/8021q/vlan.c: In function ‘vlan_ioctl_handler’:
  net/8021q/vlan.c:574:14: warning: comparison of unsigned expression >= 0 is always true [-Wtype-limits]

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 net/8021q/vlan.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 8de138d3306b..f8903c1e1010 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -571,8 +571,7 @@ static int vlan_ioctl_handler(struct net *net, void __user *arg)
 		err = -EPERM;
 		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			break;
-		if ((args.u.name_type >= 0) &&
-		    (args.u.name_type < VLAN_NAME_TYPE_HIGHEST)) {
+		if (args.u.name_type < VLAN_NAME_TYPE_HIGHEST) {
 			struct vlan_net *vn;
 
 			vn = net_generic(net, vlan_net_id);
-- 
2.9.0
