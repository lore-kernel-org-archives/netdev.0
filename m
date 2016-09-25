From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH v2 2/7] ipv6 addrconf: remove addrconf_sysctl_hop_limit()
Date: Sun, 25 Sep 2016 02:59:51 -0700
Message-ID: <1474797596-13320-2-git-send-email-zenczykowski@gmail.com>
References: <20160925.053302.1895311145903319224.davem@davemloft.net>
 <1474797596-13320-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Erik Kline <ek@google.com>,
        Lorenzo Colitti <lorenzo@google.com>
To: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:32864 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751158AbcIYKAN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2016 06:00:13 -0400
Received: by mail-pf0-f195.google.com with SMTP id q2so7553699pfj.0
        for <netdev@vger.kernel.org>; Sun, 25 Sep 2016 03:00:13 -0700 (PDT)
In-Reply-To: <1474797596-13320-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maciej Żenczykowski <maze@google.com>

replace with extra1/2 magic

Signed-off-by: Maciej Żenczykowski <maze@google.com>
---
 net/ipv6/addrconf.c | 21 ++++++---------------
 1 file changed, 6 insertions(+), 15 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 11fa1a5564d4..3a835495fb53 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -5467,20 +5467,6 @@ int addrconf_sysctl_forward(struct ctl_table *ctl, int write,
 }
 
 static
-int addrconf_sysctl_hop_limit(struct ctl_table *ctl, int write,
-                              void __user *buffer, size_t *lenp, loff_t *ppos)
-{
-	struct ctl_table lctl;
-	int min_hl = 1, max_hl = 255;
-
-	lctl = *ctl;
-	lctl.extra1 = &min_hl;
-	lctl.extra2 = &max_hl;
-
-	return proc_dointvec_minmax(&lctl, write, buffer, lenp, ppos);
-}
-
-static
 int addrconf_sysctl_mtu(struct ctl_table *ctl, int write,
 			void __user *buffer, size_t *lenp, loff_t *ppos)
 {
@@ -5713,6 +5699,9 @@ int addrconf_sysctl_ignore_routes_with_linkdown(struct ctl_table *ctl,
 	return ret;
 }
 
+static int one = 1;
+static int two_five_five = 255;
+
 static const struct ctl_table addrconf_sysctl[] = {
 	{
 		.procname	= "forwarding",
@@ -5726,7 +5715,9 @@ static const struct ctl_table addrconf_sysctl[] = {
 		.data		= &ipv6_devconf.hop_limit,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= addrconf_sysctl_hop_limit,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &one,
+		.extra2		= &two_five_five,
 	},
 	{
 		.procname	= "mtu",
-- 
2.8.0.rc3.226.g39d4020
