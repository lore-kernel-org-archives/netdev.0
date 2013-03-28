From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next] ip_tunnel: Fix off-by-one error in forming dev name.
Date: Thu, 28 Mar 2013 11:21:46 -0700
Message-ID: <1364494906-9818-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog125.obsmtp.com ([74.125.149.153]:51329 "HELO
	na3sys009aog125.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753234Ab3C1SVv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 14:21:51 -0400
Received: by mail-pd0-f200.google.com with SMTP id w10so9174442pde.11
        for <netdev@vger.kernel.org>; Thu, 28 Mar 2013 11:21:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As Ben pointed out following patch fixes bug in checking device
name length limits while forming tunnel device name.

CC: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/ipv4/ip_tunnel.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 9d96b68..e4147ec 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -284,7 +284,7 @@ static struct net_device *__ip_tunnel_create(struct net *net,
 	if (parms->name[0])
 		strlcpy(name, parms->name, IFNAMSIZ);
 	else {
-		if (strlen(ops->kind) + 3 >= IFNAMSIZ) {
+		if (strlen(ops->kind) > (IFNAMSIZ - 3)) {
 			err = -E2BIG;
 			goto failed;
 		}
-- 
1.7.1
