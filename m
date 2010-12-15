From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] sctp: fix the return value of getting the sctp partial delivery
 point
Date: Wed, 15 Dec 2010 10:10:41 +0800
Message-ID: <4D0823A1.6080307@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Vlad Yasevich <vladislav.yasevich@hp.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59989 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753536Ab0LOCKh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Dec 2010 21:10:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Get the sctp partial delivery point using SCTP_PARTIAL_DELIVERY_POINT
socket option should return 0 if success, not -ENOTSUPP.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/sctp/socket.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 1bc5203..8628e8e 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -5050,7 +5050,7 @@ static int sctp_getsockopt_partial_delivery_point(struct sock *sk, int len,
 	if (copy_to_user(optval, &val, len))
 		return -EFAULT;
 
-	return -ENOTSUPP;
+	return 0;
 }
 
 /*
-- 
1.6.5.2


