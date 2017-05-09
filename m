From: Yotam Gigi <yotamg@mellanox.com>
Subject: [PATCH net] rtnetlink: Fix the IFLA_PHYS_PORT_NAME TLV to include terminating NULL
Date: Tue,  9 May 2017 15:12:02 +0300
Message-ID: <1494331922-16451-1-git-send-email-yotamg@mellanox.com>
Cc: Yotam Gigi <yotamg@mellanox.com>,
        David Ahern <dsa@cumulusnetworks.com>
To: davem@davemloft.net, zhangshengju@cmss.chinamobile.com,
        roopa@cumulusnetworks.com, sd@queasysnail.net,
        bblanco@plumgrid.com, minipli@googlemail.com, tklauser@distanz.ch,
        nogahf@mellanox.com, moshe@mellanox.com, rshearma@brocade.com,
        daniel@iogearbox.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:52560 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752858AbdEIMIy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 08:08:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The IFLA_PHYS_PORT_NAME rtnetlink TLV length does not include the
terminating NULL character, which is different from other string typed
TLVs. Due to the fact that libnl checks for the terminating NULL in every
string typed attribute, it crashes on every RTM_GETLINK response on
drivers that implement ndo_get_phys_port_name.

Make the fill_phys_port_name function include the terminating NULL in the
TLV size by using the nla_put_string helper function.

Fixes: db24a9044ee1 ("net: add support for phys_port_name")
Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Acked-by: Jiri Pirko <jiri@mellanox.com>
---
Please consider this for stable too. Thanks!
---
 net/core/rtnetlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index c4e84c5..69daf39 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1056,7 +1056,7 @@ static int rtnl_phys_port_name_fill(struct sk_buff *skb, struct net_device *dev)
 		return err;
 	}
 
-	if (nla_put(skb, IFLA_PHYS_PORT_NAME, strlen(name), name))
+	if (nla_put_string(skb, IFLA_PHYS_PORT_NAME, name))
 		return -EMSGSIZE;
 
 	return 0;
-- 
2.4.11
