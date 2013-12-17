From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next] dccp: add check request_moduls in setup_jprobe
Date: Tue, 17 Dec 2013 20:30:17 +0800
Message-ID: <52B043D9.9090808@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <dccp@vger.kernel.org>, <netdev@vger.kernel.org>
To: <gerrit@erg.abdn.ac.uk>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:48632 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751390Ab3LQMag (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 07:30:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

when register_jprobe failed, we will try request_module. But some
time request_module will failed such as the dccp is not exist. so
check the request_module for avoiding do register_jprobe again.

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/dccp/probe.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/dccp/probe.c b/net/dccp/probe.c
index 4c6bdf9..53158d2 100644
--- a/net/dccp/probe.c
+++ b/net/dccp/probe.c
@@ -157,9 +157,12 @@ static __init int setup_jprobe(void)
 	int ret = register_jprobe(&dccp_send_probe);
 
 	if (ret) {
-		request_module("dccp");
+		if (request_module("dccp"))
+			goto out;
 		ret = register_jprobe(&dccp_send_probe);
 	}
+
+out:
 	return ret;
 }
 
-- 
1.7.12
