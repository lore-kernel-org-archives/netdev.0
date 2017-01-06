From: David Forster <dforster@brocade.com>
Subject: [PATCH] vti6: fix device register to report IFLA_INFO_KIND
Date: Fri, 6 Jan 2017 10:27:59 +0000
Message-ID: <1483698479-20445-1-git-send-email-dforster@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Dave Forster <dforster@brocade.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:41113 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S932194AbdAFK5S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 05:57:18 -0500
Received: from pps.filterd (m0048192.ppops.net [127.0.0.1])
        by mx0b-000f0801.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id v06AGa7w003807
        for <netdev@vger.kernel.org>; Fri, 6 Jan 2017 02:28:32 -0800
Received: from brmwp-exmb12.corp.brocade.com ([208.47.132.227])
        by mx0b-000f0801.pphosted.com with ESMTP id 27rjpcga69-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 06 Jan 2017 02:28:32 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vti6 interface is registered before the rtnl_link_ops block
is attached. As a result the resulting RTM_NEWLINK is missing
IFLA_INFO_KIND. Re-order attachment of rtnl_link_ops block to fix.

Signed-off-by: Dave Forster <dforster@brocade.com>
---
 net/ipv6/ip6_vti.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index f4b4a4a..d82042c 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -189,12 +189,12 @@ static int vti6_tnl_create2(struct net_device *dev)
 	struct vti6_net *ip6n = net_generic(net, vti6_net_id);
 	int err;
 
+	dev->rtnl_link_ops = &vti6_link_ops;
 	err = register_netdevice(dev);
 	if (err < 0)
 		goto out;
 
 	strcpy(t->parms.name, dev->name);
-	dev->rtnl_link_ops = &vti6_link_ops;
 
 	dev_hold(dev);
 	vti6_tnl_link(ip6n, t);
-- 
2.1.4
