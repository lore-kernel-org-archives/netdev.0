From: weiyj_lk@163.com
Subject: [PATCH -next] sctp: fix error return code in sctp_init()
Date: Mon, 13 Jun 2016 23:08:26 +0800
Message-ID: <1465830506-22752-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-15.163.com ([220.181.12.15]:43786 "EHLO m12-15.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422835AbcFMPIz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jun 2016 11:08:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Fix to return a negative error code from the error handling
case instead of 0, as done elsewhere in this function.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 net/sctp/protocol.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 40022ee..3b56ae5 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -1479,7 +1479,8 @@ static __init int sctp_init(void)
 		INIT_HLIST_HEAD(&sctp_port_hashtable[i].chain);
 	}
 
-	if (sctp_transport_hashtable_init())
+	status = sctp_transport_hashtable_init();
+	if (status)
 		goto err_thash_alloc;
 
 	pr_info("Hash tables configured (bind %d/%d)\n", sctp_port_hashsize,
