From: Chen Gang <gang.chen@asianux.com>
Subject: [PATCH] net/8021q: beautify code, name_type is unsigned int, always
 >= 0
Date: Thu, 28 Feb 2013 15:51:27 +0800
Message-ID: <512F0C7F.1010304@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: kaber@trash.net, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:33586 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751708Ab3B1Hvq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2013 02:51:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


  args.u.name_type is unsigned int, which is always >= 0

Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 net/8021q/vlan.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index a187144..0f5261a 100644
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
1.7.7.6
