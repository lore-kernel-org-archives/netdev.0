From: Chen Haiquan <oc@yunify.com>
Subject: [PATCH] vxlan: Accept user specified MTU value when create new vxlan link
Date: Fri, 27 May 2016 10:49:11 +0800
Message-ID: <1464317351-22316-1-git-send-email-oc@yunify.com>
Cc: netdev@vger.kernel.org, Chen Haiquan <oc@yunify.com>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from m50-212.qiye.163.com ([123.125.50.212]:46366 "EHLO
	m50-212.qiye.163.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932168AbcE0Cym (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2016 22:54:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When create a new vxlan link, example:
  ip link add vtap mtu 1440 type vxlan vni 1 dev eth0

The argument "mtu" has no effect, because it is not set to conf->mtu. The
default value is used in vxlan_dev_configure function.

This problem was introduced by commit 0dfbdf4102b9 (vxlan: Factor out device 
configuration).

Fixes: 0dfbdf4102b9 (vxlan: Factor out device configuration) 

Signed-off-by:  Chen Haiquan <oc@yunify.com>
---
 drivers/net/vxlan.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 8ff30c3..f999db2 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -3086,6 +3086,9 @@ static int vxlan_newlink(struct net *src_net, struct net_device *dev,
 	if (data[IFLA_VXLAN_REMCSUM_NOPARTIAL])
 		conf.flags |= VXLAN_F_REMCSUM_NOPARTIAL;
 
+	if (tb[IFLA_MTU])
+		conf.mtu = nla_get_u32(tb[IFLA_MTU]);
+
 	err = vxlan_dev_configure(src_net, dev, &conf);
 	switch (err) {
 	case -ENODEV:
-- 
2.7.4
