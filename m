From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] rtnetlink: fix error return code in rtnl_link_fill()
Date: Wed, 27 Mar 2013 21:22:45 +0800
Message-ID: <CAPgLHd8F8-uRfAi4R=xqHa76X8N9P+-UosF-6zC=OXStKbcP-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: davem@davemloft.net, john.r.fastabend@intel.com, jiri@resnulli.us,
	edumazet@google.com, vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:43541 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751049Ab3C0NWq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 09:22:46 -0400
Received: by mail-bk0-f46.google.com with SMTP id je9so1804900bkc.33
        for <netdev@vger.kernel.org>; Wed, 27 Mar 2013 06:22:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Fix to return a negative error code from the error handling case
instead of 0(possible overwrite to 0 by ops->fill_xstats call),
as returned elsewhere in this function.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 net/core/rtnetlink.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 5fb8d7e..b65441d 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -496,8 +496,10 @@ static int rtnl_link_fill(struct sk_buff *skb, const struct net_device *dev)
 	}
 	if (ops->fill_info) {
 		data = nla_nest_start(skb, IFLA_INFO_DATA);
-		if (data == NULL)
+		if (data == NULL) {
+			err = -EMSGSIZE;
 			goto err_cancel_link;
+		}
 		err = ops->fill_info(skb, dev);
 		if (err < 0)
 			goto err_cancel_data;
