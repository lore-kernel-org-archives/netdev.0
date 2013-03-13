From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] tuntap: remove unused variable in __tun_detach()
Date: Wed, 13 Mar 2013 21:03:58 +0800
Message-ID: <CAPgLHd-v-daRHrDqoencJOTTvxLU_RD44BWzvdHd6j5Qrr8J5Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: davem@davemloft.net, jasowang@redhat.com, mst@redhat.com,
	edumazet@google.com, nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f54.google.com ([209.85.214.54]:36148 "EHLO
	mail-bk0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932086Ab3CMNEA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 09:04:00 -0400
Received: by mail-bk0-f54.google.com with SMTP id w5so443673bku.13
        for <netdev@vger.kernel.org>; Wed, 13 Mar 2013 06:03:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

The variable dev is initialized but never used
otherwise, so remove the unused variable.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/tun.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index b7c457a..95837c1 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -409,14 +409,12 @@ static void __tun_detach(struct tun_file *tfile, bool clean)
 {
 	struct tun_file *ntfile;
 	struct tun_struct *tun;
-	struct net_device *dev;
 
 	tun = rtnl_dereference(tfile->tun);
 
 	if (tun && !tfile->detached) {
 		u16 index = tfile->queue_index;
 		BUG_ON(index >= tun->numqueues);
-		dev = tun->dev;
 
 		rcu_assign_pointer(tun->tfiles[index],
 				   tun->tfiles[tun->numqueues - 1]);
