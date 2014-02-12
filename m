From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH v3 1/2] sctp: fix a missed .data initialization
Date: Wed, 12 Feb 2014 09:44:43 +0800
Message-ID: <1392169484-8256-2-git-send-email-wangweidong1@huawei.com>
References: <1392169484-8256-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dborkman@redhat.com>, <sergei.shtylyov@cogentembedded.com>,
	<netdev@vger.kernel.org>
To: <nhorman@tuxdriver.com>, <davem@davemloft.net>,
	<vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:42716 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752545AbaBLBqq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 20:46:46 -0500
In-Reply-To: <1392169484-8256-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As commit 3c68198e75111a90("sctp: Make hmac algorithm selection for
 cookie generation dynamic"), we miss the .data initialization.
If we don't use the net_namespace, the problem that parts of the
sysctl configuration won't be isolation and won't occur.

In sctp_sysctl_net_register(), we register the sysctl for each
net, in the for(), we use the 'table[i].data' as check condition, so
when the 'i' is the index of sctp_hmac_alg, the data is NULL, then
break. So add the .data initialization.

Acked-by: Neil Horman <nhorman@tuxdriver.com>
Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/sctp/sysctl.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index 7135e61..d354de5 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -151,6 +151,7 @@ static struct ctl_table sctp_net_table[] = {
 	},
 	{
 		.procname	= "cookie_hmac_alg",
+		.data		= &init_net.sctp.sctp_hmac_alg,
 		.maxlen		= 8,
 		.mode		= 0644,
 		.proc_handler	= proc_sctp_do_hmac_alg,
-- 
1.7.12
