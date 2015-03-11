From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] dsa: change "select" to "depends on" for switchdev in Kconfig
Date: Wed, 11 Mar 2015 17:44:28 +0100
Message-ID: <1426092268-1713-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, f.fainelli@gmail.com, sfeldma@gmail.com,
	rdunlap@infradead.org, alexei.starovoitov@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:45536 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752625AbbCKQoc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 12:44:32 -0400
Received: by wibbs8 with SMTP id bs8so13357884wib.4
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 09:44:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This would fix randconfig compile error:
net/built-in.o: In function `netdev_switch_fib_ipv4_abort':
(.text+0xf7811): undefined reference to `fib_flush_external'

Also it fixes following warning:
warning: (NET_DSA) selects NET_SWITCHDEV which has unmet direct dependencies (NET && INET)

Suggested-by: Randy Dunlap <rdunlap@infradead.org>
Suggested-by: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/dsa/Kconfig | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
index b45206e..9379a9c 100644
--- a/net/dsa/Kconfig
+++ b/net/dsa/Kconfig
@@ -6,9 +6,8 @@ config HAVE_NET_DSA
 
 config NET_DSA
 	tristate
-	depends on HAVE_NET_DSA
+	depends on HAVE_NET_DSA && NET_SWITCHDEV
 	select PHYLIB
-	select NET_SWITCHDEV
 
 if NET_DSA
 
-- 
1.9.3
