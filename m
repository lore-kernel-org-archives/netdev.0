From: Zhang JieJing <kzjeef@gmail.com>
Subject: [PATCH] xfrm: fix a possible leak of dev reference count.
Date: Sun, 8 Aug 2010 21:34:12 +0800
Message-ID: <AANLkTi==t8MGGLDxMLZsHtRoLqwhgNskU83wBw7-+ZyJ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Dan Carpenter <error27@gmail.com>, Zhang Jiejing <kzjeef@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:44133 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753700Ab0HHNeQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Aug 2010 09:34:16 -0400
Received: by qwh6 with SMTP id 6so6426559qwh.19
        for <netdev@vger.kernel.org>; Sun, 08 Aug 2010 06:34:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

call dev_put(dev) on error path.

Signed-off-by: JieJing.Zhang <kzjeef@gmail.com>
---
 net/ipv4/xfrm4_policy.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 1705476..d2a4873 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -81,8 +81,10 @@ static int xfrm4_fill_dst(struct xfrm_dst *xdst,
struct net_device *dev,
 	dev_hold(dev);

 	xdst->u.rt.idev = in_dev_get(dev);
-	if (!xdst->u.rt.idev)
+	if (!xdst->u.rt.idev) {
+		dev_put(dev);
 		return -ENODEV;
+	}

 	xdst->u.rt.peer = rt->peer;
 	if (rt->peer)
-- 
1.7.0.4
