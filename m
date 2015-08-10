From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] hamradio/kiss: missing error code in mkiss_open()
Date: Tue, 11 Aug 2015 00:39:22 +0300
Message-ID: <20150810213922.GA3380@mwanda>
References: <CA+55aFy1af43uxH1r=_CxTCgPNN802YA+H26Vbbkb=rknqZuXQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	netdev@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	RUC_Soft_Sec <zy900702@163.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:30359 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932726AbbHJVju (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 17:39:50 -0400
Content-Disposition: inline
In-Reply-To: <CA+55aFy1af43uxH1r=_CxTCgPNN802YA+H26Vbbkb=rknqZuXQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If register_netdev() fails we return success but we should return an
error code instead.

Reported-by: RUC_Soft_Sec <zy900702@163.com>
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/hamradio/mkiss.c b/drivers/net/hamradio/mkiss.c
index 2ffbf13..dcb6bb7 100644
--- a/drivers/net/hamradio/mkiss.c
+++ b/drivers/net/hamradio/mkiss.c
@@ -732,7 +732,8 @@ static int mkiss_open(struct tty_struct *tty)
 		goto out_free_netdev;
 	}
 
-	if (register_netdev(dev))
+	err = register_netdev(dev);
+	if (err)
 		goto out_free_buffers;
 
 	/* after register_netdev() - because else printk smashes the kernel */
