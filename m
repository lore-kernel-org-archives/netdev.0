From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH v2 1/7] ipv6 addrconf: enable use of proc_dointvec_minmax in addrconf_sysctl
Date: Sun, 25 Sep 2016 02:59:50 -0700
Message-ID: <1474797596-13320-1-git-send-email-zenczykowski@gmail.com>
References: <20160925.053302.1895311145903319224.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Erik Kline <ek@google.com>,
        Lorenzo Colitti <lorenzo@google.com>
To: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35035 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750727AbcIYKAN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2016 06:00:13 -0400
Received: by mail-pf0-f196.google.com with SMTP id 6so7556692pfl.2
        for <netdev@vger.kernel.org>; Sun, 25 Sep 2016 03:00:12 -0700 (PDT)
In-Reply-To: <20160925.053302.1895311145903319224.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maciej Żenczykowski <maze@google.com>

Signed-off-by: Maciej Żenczykowski <maze@google.com>
---
 net/ipv6/addrconf.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 2f1f5d439788..11fa1a5564d4 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -6044,8 +6044,14 @@ static int __addrconf_sysctl_register(struct net *net, char *dev_name,
 
 	for (i = 0; table[i].data; i++) {
 		table[i].data += (char *)p - (char *)&ipv6_devconf;
-		table[i].extra1 = idev; /* embedded; no ref */
-		table[i].extra2 = net;
+		/* If one of these is already set, then it is not safe to
+		 * overwrite either of them: this makes proc_dointvec_minmax
+		 * usable.
+		 */
+		if (!table[i].extra1 && !table[i].extra2) {
+			table[i].extra1 = idev; /* embedded; no ref */
+			table[i].extra2 = net;
+		}
 	}
 
 	snprintf(path, sizeof(path), "net/ipv6/conf/%s", dev_name);
-- 
2.8.0.rc3.226.g39d4020
