From: Wang Weidong <wangweidong1@huawei.com>
Subject: [net-next 2/2] sctp: add a checking for sctp_sysctl_net_register
Date: Thu, 8 May 2014 20:55:02 +0800
Message-ID: <1399553702-7960-3-git-send-email-wangweidong1@huawei.com>
References: <1399553702-7960-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-sctp@vger.kernel.org>, <netdev@vger.kernel.org>
To: <davem@davemloft.net>, <vyasevich@gmail.com>,
	<nhorman@tuxdriver.com>, <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:45098 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753494AbaEHM45 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 08:56:57 -0400
In-Reply-To: <1399553702-7960-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When register_net_sysctl failed, we should free the
sysctl_table.

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/sctp/sysctl.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index ee80eb4..7e5eb75 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -447,6 +447,10 @@ int sctp_sysctl_net_register(struct net *net)
 		table[i].data += (char *)(&net->sctp) - (char *)&init_net.sctp;
 
 	net->sctp.sysctl_header = register_net_sysctl(net, "net/sctp", table);
+	if (net->sctp.sysctl_header == NULL) {
+		kfree(table);
+		return -ENOMEM;
+	}
 	return 0;
 }
 
-- 
1.7.12
