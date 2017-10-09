From: Matteo Croce <mcroce@redhat.com>
Subject: [RFC net-next] ppp: allow usage in namespaces
Date: Mon,  9 Oct 2017 14:59:41 +0200
Message-ID: <20171009125941.15452-1-mcroce@redhat.com>
Cc: David Miller <davem@davemloft.net>
To: Paul Mackerras <paulus@samba.org>, linux-ppp@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:43243 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754352AbdJIM7o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 08:59:44 -0400
Received: by mail-wm0-f45.google.com with SMTP id m72so11461584wmc.0
        for <netdev@vger.kernel.org>; Mon, 09 Oct 2017 05:59:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check for CAP_NET_ADMIN with ns_capable() instead of capable()
to allow usage of ppp in user namespace other than the init one.

Signed-off-by: Matteo Croce <mcroce@redhat.com>
---
 drivers/net/ppp/ppp_generic.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index a404552555d4..be5634b4835b 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -389,7 +389,7 @@ static int ppp_open(struct inode *inode, struct file *file)
 	/*
 	 * This could (should?) be enforced by the permissions on /dev/ppp.
 	 */
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(file->f_cred->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 	return 0;
 }
-- 
2.13.6
