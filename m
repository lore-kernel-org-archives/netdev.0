From: Veaceslav Falico <vfalico@gmail.com>
Subject: [PATCH net-next] net: print a notification on device rename
Date: Thu, 17 Jul 2014 20:33:32 +0200
Message-ID: <1405622012-5511-1-git-send-email-vfalico@gmail.com>
Cc: Veaceslav Falico <vfalico@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	stephen hemminger <stephen@networkplumber.org>,
	Jerry Chu <hkchu@google.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Laight <David.Laight@ACULAB.COM>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26228 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751045AbaGQSiZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jul 2014 14:38:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently it's done silently (from the kernel part), and thus it might be
hard to track the renames from logs.

Add a simple netdev_info() to notify the rename, but only in case the
previous name was valid.

CC: "David S. Miller" <davem@davemloft.net>
CC: Eric Dumazet <edumazet@google.com>
CC: Vlad Yasevich <vyasevic@redhat.com>
CC: stephen hemminger <stephen@networkplumber.org>
CC: Jerry Chu <hkchu@google.com>
CC: Ben Hutchings <bhutchings@solarflare.com>
CC: David Laight <David.Laight@ACULAB.COM>
Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
---
 net/core/dev.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index 239722a..d14ebf0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1113,6 +1113,9 @@ int dev_change_name(struct net_device *dev, const char *newname)
 		return err;
 	}
 
+	if (oldname[0] && !strchr(oldname, '%'))
+		netdev_info(dev, "renamed from %s\n", oldname);
+
 	old_assign_type = dev->name_assign_type;
 	dev->name_assign_type = NET_NAME_RENAMED;
 
-- 
1.8.4
