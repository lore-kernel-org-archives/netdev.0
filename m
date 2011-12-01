From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2] net: net_device flags is an unsigned int
Date: Thu, 01 Dec 2011 08:42:26 +0100
Message-ID: <1322725346.2577.31.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:43579 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752582Ab1LAHmc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 02:42:32 -0500
Received: by eeaq14 with SMTP id q14so265943eea.19
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 23:42:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit b00055aacdb ([NET] core: add RFC2863 operstate) changed
net_device flags from unsigned short to unsigned int.

Some core functions still assume its an unsigned short.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/dev.c |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 5a13edf..2cf02f9 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4539,7 +4539,7 @@ static void dev_change_rx_flags(struct net_device *dev, int flags)
 
 static int __dev_set_promiscuity(struct net_device *dev, int inc)
 {
-	unsigned short old_flags = dev->flags;
+	unsigned int old_flags = dev->flags;
 	uid_t uid;
 	gid_t gid;
 
@@ -4596,7 +4596,7 @@ static int __dev_set_promiscuity(struct net_device *dev, int inc)
  */
 int dev_set_promiscuity(struct net_device *dev, int inc)
 {
-	unsigned short old_flags = dev->flags;
+	unsigned int old_flags = dev->flags;
 	int err;
 
 	err = __dev_set_promiscuity(dev, inc);
@@ -4623,7 +4623,7 @@ EXPORT_SYMBOL(dev_set_promiscuity);
 
 int dev_set_allmulti(struct net_device *dev, int inc)
 {
-	unsigned short old_flags = dev->flags;
+	unsigned int old_flags = dev->flags;
 
 	ASSERT_RTNL();
 
@@ -4726,7 +4726,7 @@ EXPORT_SYMBOL(dev_get_flags);
 
 int __dev_change_flags(struct net_device *dev, unsigned int flags)
 {
-	int old_flags = dev->flags;
+	unsigned int old_flags = dev->flags;
 	int ret;
 
 	ASSERT_RTNL();
@@ -4809,10 +4809,10 @@ void __dev_notify_flags(struct net_device *dev, unsigned int old_flags)
  *	Change settings on device based state flags. The flags are
  *	in the userspace exported format.
  */
-int dev_change_flags(struct net_device *dev, unsigned flags)
+int dev_change_flags(struct net_device *dev, unsigned int flags)
 {
-	int ret, changes;
-	int old_flags = dev->flags;
+	int ret;
+	unsigned int changes, old_flags = dev->flags;
 
 	ret = __dev_change_flags(dev, flags);
 	if (ret < 0)
