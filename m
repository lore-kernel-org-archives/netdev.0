From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH net] net: ipmr: ipmr_get_table() returns NULL
Date: Wed, 12 Jul 2017 10:56:47 +0300
Message-ID: <20170712075647.zyz6pkppyerl4ktf@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        Donald Sharp <sharpd@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:22449 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756778AbdGLH5g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Jul 2017 03:57:36 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ipmr_get_table() function doesn't return error pointers it returns
NULL on error.

Fixes: 4f75ba6982bc ("net: ipmr: Add ipmr_rtm_getroute")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index bb909f1d7537..06863ea3fc5b 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -2431,8 +2431,8 @@ static int ipmr_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh,
 	tableid = tb[RTA_TABLE] ? nla_get_u32(tb[RTA_TABLE]) : 0;
 
 	mrt = ipmr_get_table(net, tableid ? tableid : RT_TABLE_DEFAULT);
-	if (IS_ERR(mrt)) {
-		err = PTR_ERR(mrt);
+	if (!mrt) {
+		err = -ENOENT;
 		goto errout_free;
 	}
 
