From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH 2/2] net: ipv6: ndisc: Fix warning when CONFIG_SYSCTL=n
Date: Sat, 16 Nov 2013 00:52:08 -0200
Message-ID: <1384570328-21666-2-git-send-email-festevam@gmail.com>
References: <1384570328-21666-1-git-send-email-festevam@gmail.com>
Cc: netdev@vger.kernel.org, Fabio Estevam <fabio.estevam@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f52.google.com ([209.85.213.52]:55661 "EHLO
	mail-yh0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753620Ab3KPCwd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Nov 2013 21:52:33 -0500
Received: by mail-yh0-f52.google.com with SMTP id i57so2266797yha.11
        for <netdev@vger.kernel.org>; Fri, 15 Nov 2013 18:52:33 -0800 (PST)
In-Reply-To: <1384570328-21666-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>

When CONFIG_SYSCTL=n the following build warning happens:

net/ipv6/ndisc.c:1730:1: warning: label 'out' defined but not used [-Wunused-label]

The 'out' label is only used when CONFIG_SYSCTL=y, so move it inside the 
'ifdef CONFIG_SYSCTL' block.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 net/ipv6/ndisc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index f8a55ff..3512177 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1726,8 +1726,8 @@ int __init ndisc_init(void)
 				    &ndisc_ifinfo_sysctl_change);
 	if (err)
 		goto out_unregister_pernet;
-#endif
 out:
+#endif
 	return err;
 
 #ifdef CONFIG_SYSCTL
-- 
1.8.1.2
