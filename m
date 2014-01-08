From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] openvswitch: Use kmem_cache_free() instead of kfree()
Date: Wed, 8 Jan 2014 18:13:14 +0800
Message-ID: <CAPgLHd_jaxf4jsvUzBhE_RFioHgZzvmWhA=d_J5phUOhBGy49g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, dev@openvswitch.org,
	netdev@vger.kernel.org
To: jesse@nicira.com, pshelar@nicira.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f54.google.com ([209.85.214.54]:33280 "EHLO
	mail-bk0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752932AbaAHKNQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 05:13:16 -0500
Received: by mail-bk0-f54.google.com with SMTP id v16so607770bkz.27
        for <netdev@vger.kernel.org>; Wed, 08 Jan 2014 02:13:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

memory allocated by kmem_cache_alloc() should be freed using
kmem_cache_free(), not kfree().

Fixes: e298e5057006 ('openvswitch: Per cpu flow stats.')
Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 net/openvswitch/flow_table.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
index b430d42..c58a0fe 100644
--- a/net/openvswitch/flow_table.c
+++ b/net/openvswitch/flow_table.c
@@ -104,7 +104,7 @@ struct sw_flow *ovs_flow_alloc(bool percpu_stats)
 	}
 	return flow;
 err:
-	kfree(flow);
+	kmem_cache_free(flow_cache, flow);
 	return ERR_PTR(-ENOMEM);
 }
 
