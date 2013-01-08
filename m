From: Jiri Pirko <jiri@resnulli.us>
Subject: [RFC patch net-next] ipv4: use bcast as dst address in case IFF_NOARP is set
Date: Tue,  8 Jan 2013 14:02:42 +0100
Message-ID: <1357650162-5554-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, shemminger@vyatta.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:62648 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756299Ab3AHNCt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 08:02:49 -0500
Received: by mail-wg0-f54.google.com with SMTP id fg15so311545wgb.9
        for <netdev@vger.kernel.org>; Tue, 08 Jan 2013 05:02:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When IFF_NOARP is set on a device, dev->dev_addr is used as *dst*
addr of sent frames. That does not make sense. Use rather bcast address
instead.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/ipv4/arp.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 9547a273..19d5ac2 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -290,11 +290,11 @@ static int arp_constructor(struct neighbour *neigh)
 		if (neigh->type == RTN_MULTICAST) {
 			neigh->nud_state = NUD_NOARP;
 			arp_mc_map(addr, neigh->ha, dev, 1);
-		} else if (dev->flags & (IFF_NOARP | IFF_LOOPBACK)) {
+		} else if (dev->flags & IFF_LOOPBACK) {
 			neigh->nud_state = NUD_NOARP;
 			memcpy(neigh->ha, dev->dev_addr, dev->addr_len);
 		} else if (neigh->type == RTN_BROADCAST ||
-			   (dev->flags & IFF_POINTOPOINT)) {
+			   (dev->flags & (IFF_POINTOPOINT | IFF_NOARP))) {
 			neigh->nud_state = NUD_NOARP;
 			memcpy(neigh->ha, dev->broadcast, dev->addr_len);
 		}
-- 
1.8.1
