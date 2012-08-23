From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] airo: use is_zero_ether_addr() and is_broadcast_ether_addr()
Date: Thu, 23 Aug 2012 15:17:09 +0800
Message-ID: <CAPgLHd8MssMFM7G8SpAQQAr-i6nbgtHEPEPKC3ggGLAegpeRGw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:44712 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757986Ab2HWHRK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 03:17:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Using is_zero_ether_addr() and is_broadcast_ether_addr() instead of
directly use memcmp() to determine if the ethernet address is all zeros.

spatch with a semantic match is used to found this problem.
(http://coccinelle.lip6.fr/)

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/wireless/airo.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index f9f15bb..17c599d 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -5976,13 +5976,11 @@ static int airo_set_wap(struct net_device *dev,
 	Cmd cmd;
 	Resp rsp;
 	APListRid APList_rid;
-	static const u8 any[ETH_ALEN] = { 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF };
-	static const u8 off[ETH_ALEN] = { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };
 
 	if (awrq->sa_family != ARPHRD_ETHER)
 		return -EINVAL;
-	else if (!memcmp(any, awrq->sa_data, ETH_ALEN) ||
-	         !memcmp(off, awrq->sa_data, ETH_ALEN)) {
+	else if (is_broadcast_ether_addr(awrq->sa_data) ||
+		 is_zero_ether_addr(awrq->sa_data)) {
 		memset(&cmd, 0, sizeof(cmd));
 		cmd.cmd=CMD_LOSE_SYNC;
 		if (down_interruptible(&local->sem))
