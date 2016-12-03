From: Pan Bian <bianpan201602@163.com>
Subject: [PATCH 1/1] net: dcb: set error code on failures
Date: Sat,  3 Dec 2016 21:49:08 +0800
Message-ID: <1480772948-7087-1-git-send-email-bianpan201602@163.com>
Cc: linux-kernel@vger.kernel.org, Pan Bian <bianpan2016@163.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m50-134.163.com ([123.125.50.134]:52755 "EHLO m50-134.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751070AbcLCNt4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 3 Dec 2016 08:49:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pan Bian <bianpan2016@163.com>

In function dcbnl_cee_fill(), returns the value of variable err on
errors. However, on some error paths (e.g. nla put fails), its value may
be 0. It may be better to explicitly set a negative errno to variable
err before returning.

Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=188881

Signed-off-by: Pan Bian <bianpan2016@163.com>
---
 net/dcb/dcbnl.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 4f6c186..3202d75 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -1353,6 +1353,7 @@ static int dcbnl_cee_fill(struct sk_buff *skb, struct net_device *netdev)
 dcb_unlock:
 	spin_unlock_bh(&dcb_lock);
 nla_put_failure:
+	err = -EMSGSIZE;
 	return err;
 }
 
-- 
1.9.1
