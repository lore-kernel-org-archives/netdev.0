From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] tuntap: fix error return code in tun_set_iff()
Date: Fri, 12 Apr 2013 21:17:12 +0800
Message-ID: <CAPgLHd9WrbgeYH9pw81kQn9sv=On8e399qAOth6MWprF6PS5pg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: davem@davemloft.net, jasowang@redhat.com, mst@redhat.com,
	edumazet@google.com, nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f51.google.com ([209.85.214.51]:53863 "EHLO
	mail-bk0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752581Ab3DLNRO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 09:17:14 -0400
Received: by mail-bk0-f51.google.com with SMTP id y8so1388030bkt.10
        for <netdev@vger.kernel.org>; Fri, 12 Apr 2013 06:17:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Fix to return a negative error code from the error handling
case instead of 0, as returned elsewhere in this function.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/tun.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index b7c457a..729ed53 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1594,7 +1594,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 
 		if (tun->flags & TUN_TAP_MQ &&
 		    (tun->numqueues + tun->numdisabled > 1))
-			return err;
+			return -EBUSY;
 	}
 	else {
 		char *name;
