From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] sctp: fix error return code in __sctp_connect()
Date: Wed, 3 Apr 2013 21:02:28 +0800
Message-ID: <CAPgLHd-X5Qw64BnaSMr2ny6==jXGpRAYC7_1MGhP2v_GcVeApQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org
To: vyasevich@gmail.com, sri@us.ibm.com, nhorman@tuxdriver.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f54.google.com ([209.85.214.54]:53154 "EHLO
	mail-bk0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754998Ab3DCNCa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Apr 2013 09:02:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Fix to return a negative error code from the error handling
case instead of 0, as returned elsewhere in this function.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 net/sctp/socket.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index dd21ae3..f631c5f 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -1119,9 +1119,10 @@ static int __sctp_connect(struct sock* sk,
 		/* Make sure the destination port is correctly set
 		 * in all addresses.
 		 */
-		if (asoc && asoc->peer.port && asoc->peer.port != port)
+		if (asoc && asoc->peer.port && asoc->peer.port != port) {
+			err = -EINVAL;
 			goto out_free;
-
+		}
 
 		/* Check if there already is a matching association on the
 		 * endpoint (other than the one created here).
