From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tun: honor IFF_UP in tun_get_user()
Date: Wed, 16 Dec 2015 08:57:37 -0800
Message-ID: <1450285057.8474.80.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Curt Wohlgemuth <curtw@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34055 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966106AbbLPQ5j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 11:57:39 -0500
Received: by mail-pa0-f49.google.com with SMTP id wq6so26313626pac.1
        for <netdev@vger.kernel.org>; Wed, 16 Dec 2015 08:57:39 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

If a tun interface is turned down, we should not allow packet injection
into the kernel.

Kernel does not send packets to the tun already.

TUNATTACHFILTER can not be used as only tun_net_xmit() is taking care
of it.

Reported-by: Curt Wohlgemuth <curtw@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/tun.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index f0db770e8b2f..88bb8cc3555b 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1095,6 +1095,9 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 	u32 rxhash;
 	ssize_t n;
 
+	if (!(tun->dev->flags & IFF_UP))
+		return -EIO;
+
 	if (!(tun->flags & IFF_NO_PI)) {
 		if (len < sizeof(pi))
 			return -EINVAL;
