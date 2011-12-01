From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: net_device flags is an unsigned int
Date: Thu, 01 Dec 2011 05:34:37 +0100
Message-ID: <1322714077.2577.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:45218 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754002Ab1LAEem (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 23:34:42 -0500
Received: by eaak14 with SMTP id k14so1616721eaa.19
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 20:34:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit b00055aacdb ([NET] core: add RFC2863 operstate) changed
net_device flags from unsigned short to unsigned int.

Some core functions still assume its an unsigned short.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/dev.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 1482eea..1c345cf 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4538,7 +4538,7 @@ static void dev_change_rx_flags(struct net_device *dev, int flags)
 
 static int __dev_set_promiscuity(struct net_device *dev, int inc)
 {
-	unsigned short old_flags = dev->flags;
+	typeof(dev->flags) old_flags = dev->flags;
 	uid_t uid;
 	gid_t gid;
 
@@ -4595,7 +4595,7 @@ static int __dev_set_promiscuity(struct net_device *dev, int inc)
  */
 int dev_set_promiscuity(struct net_device *dev, int inc)
 {
-	unsigned short old_flags = dev->flags;
+	typeof(dev->flags) old_flags = dev->flags;
 	int err;
 
 	err = __dev_set_promiscuity(dev, inc);
@@ -4622,7 +4622,7 @@ EXPORT_SYMBOL(dev_set_promiscuity);
 
 int dev_set_allmulti(struct net_device *dev, int inc)
 {
-	unsigned short old_flags = dev->flags;
+	typeof(dev->flags) old_flags = dev->flags;
 
 	ASSERT_RTNL();
 
