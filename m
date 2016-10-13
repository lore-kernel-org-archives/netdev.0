From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch -next] net: rtnl: info leak in rtnl_fill_vfinfo()
Date: Thu, 13 Oct 2016 11:45:28 +0300
Message-ID: <20161013084528.GA16198@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Nogah Frankel <nogahf@mellanox.com>,
        Brenden Blanco <bblanco@plumgrid.com>, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        Moshe Shemesh <moshe@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:25557 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752180AbcJMIqi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 04:46:38 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The "vf_vlan_info" struct ends with a 2 byte struct hole so we have to
memset it to ensure that no stack information is revealed to user space.

Fixes: 79aab093a0b5 ('net: Update API for VF vlan protocol 802.1ad support')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index b06d2f4..fb7348f 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1144,6 +1144,8 @@ static noinline_for_stack int rtnl_fill_vfinfo(struct sk_buff *skb,
 	if (dev->netdev_ops->ndo_get_vf_config(dev, vfs_num, &ivi))
 		return 0;
 
+	memset(&vf_vlan_info, 0, sizeof(vf_vlan_info));
+
 	vf_mac.vf =
 		vf_vlan.vf =
 		vf_vlan_info.vf =
