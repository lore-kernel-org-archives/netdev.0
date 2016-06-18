From: Shanker Wang <shanker@tuna.tsinghua.edu.cn>
Subject: [PATCH] net:ppp: replace too strict capability restriction on opening  /dev/ppp
Date: Sun, 19 Jun 2016 01:38:55 +0200
Message-ID: <44A9BDB8-754B-4402-BD09-6381229C07C5@tuna.tsinghua.edu.cn>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Richard Weinberger <richard.weinberger@gmail.com>,
	Guillaume Nault <g.nault@alphalink.fr>,
	Miao Wang <shankerwangmiao@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34393 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751114AbcFRXkv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jun 2016 19:40:51 -0400
Received: by mail-wm0-f68.google.com with SMTP id 187so5843296wmz.1
        for <netdev@vger.kernel.org>; Sat, 18 Jun 2016 16:40:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the check for CAP_NET_ADMIN in the initial namespace
when opening /dev/open. Instead, CAP_NET_ADMIN is checked in the user
namespace the net namespace was created so that /dev/ppp cat get opened
in a unprivileged container.

Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Richard Weinberger <richard.weinberger@gmail.com>
Cc: Guillaume Nault <g.nault@alphalink.fr>
Cc: Miao Wang <shankerwangmiao@gmail.com>
Signed-off-by: Miao Wang <shanker@tuna.tsinghua.edu.cn>
---
 drivers/net/ppp/ppp_generic.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index f572b31..4b3b2b5 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -380,7 +380,7 @@ static int ppp_open(struct inode *inode, struct file *file)
 	/*
 	 * This could (should?) be enforced by the permissions on /dev/ppp.
 	 */
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(current->nsproxy->net_ns->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 	return 0;
 }
-- 
2.5.2
