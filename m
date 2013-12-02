From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH] sctp: make the max_burst min value to 1
Date: Mon, 2 Dec 2013 14:51:45 +0800
Message-ID: <529C2E01.3090005@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linux-sctp@vger.kernel.org>, <netdev@vger.kernel.org>,
	<dingtianhong@huawei.com>
To: Vlad Yasevich <vyasevich@gmail.com>, <nhorman@tuxdriver.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:58082 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752556Ab3LBGwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 01:52:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Weidong <wangweidong1@huawei.com>

when I setted the max_burst to 0, do the lksctp-tools I got hang.
I found sctp_transport_burst_limited would make the cwnd to 0.
so I make the max_burst min value to 1.
Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/sctp/sysctl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index 7637e8e..46832d3 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -135,7 +135,7 @@ static struct ctl_table sctp_net_table[] = {
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.extra1		= &zero,
+		.extra1		= &one,
 		.extra2		= &int_max
 	},
 	{
-- 
1.7.12
