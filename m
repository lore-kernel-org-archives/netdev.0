From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next] sctp: add a checking for sctp_sysctl_net_register
Date: Thu, 8 May 2014 15:55:05 +0800
Message-ID: <536B3859.2050908@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>,
	<linux-sctp@vger.kernel.org>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:18216 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752845AbaEHH4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 03:56:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When register_net_sysctl failed, we should free the
sysctl_table while the net_namespace is not init_net.

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/sctp/sysctl.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index 844d2b0..4c17694 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -450,6 +450,11 @@ int sctp_sysctl_net_register(struct net *net)
 	}
 
 	net->sctp.sysctl_header = register_net_sysctl(net, "net/sctp", table);
+	if (net->sctp.sysctl_header == NULL) {
+		if (!net_eq(net, &init_net))
+			kfree(table);
+		return -ENOMEM;
+	}
 	return 0;
 }
 
-- 
1.7.12
