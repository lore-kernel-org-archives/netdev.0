From: Rami Rosen <ramirose@gmail.com>
Subject: [net-next patch] tun: change tun_get_iff() prototype.
Date: Fri, 23 Nov 2012 15:58:10 +0200
Message-ID: <1353679090-27892-1-git-send-email-ramirose@gmail.com>
Cc: maxk@qualcomm.com, netdev@vger.kernel.org,
	Rami Rosen <ramirose@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:38604 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752720Ab2KWN7F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Nov 2012 08:59:05 -0500
Received: by mail-we0-f174.google.com with SMTP id d7so2427280wer.19
        for <netdev@vger.kernel.org>; Fri, 23 Nov 2012 05:59:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes tun_get_iff() prototype to return void as it never fails.

Signed-off-by: Rami Rosen <ramirose@gmail.com>
---
 drivers/net/tun.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index b01e8c0..3bd9932 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1662,7 +1662,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 	return err;
 }
 
-static int tun_get_iff(struct net *net, struct tun_struct *tun,
+static void tun_get_iff(struct net *net, struct tun_struct *tun,
 		       struct ifreq *ifr)
 {
 	tun_debug(KERN_INFO, tun, "tun_get_iff\n");
@@ -1671,7 +1671,6 @@ static int tun_get_iff(struct net *net, struct tun_struct *tun,
 
 	ifr->ifr_flags = tun_flags(tun);
 
-	return 0;
 }
 
 /* This is like a cut-down ethtool ops, except done via tun fd so no
@@ -1847,9 +1846,7 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 	ret = 0;
 	switch (cmd) {
 	case TUNGETIFF:
-		ret = tun_get_iff(current->nsproxy->net_ns, tun, &ifr);
-		if (ret)
-			break;
+		tun_get_iff(current->nsproxy->net_ns, tun, &ifr);
 
 		if (copy_to_user(argp, &ifr, ifreq_len))
 			ret = -EFAULT;
-- 
1.7.11.7
