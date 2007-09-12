From: Jiri Kosina <jkosina@suse.cz>
Subject: [PATCH] IPV6: fix source address selection
Date: Thu, 13 Sep 2007 00:56:00 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0709130044300.7343@jikos.suse.cz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Jiri Bohac <jbohac@suse.cz>,
	Petr Baudis <pasky@suse.cz>
To: davem@davemloft.net, nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:45014 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753729AbXILW4P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Sep 2007 18:56:15 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Kosina <jkosina@suse.cz>

[PATCH] IPV6: fix source address selection

The commit 95c385 broke proper source address selection for cases in which 
there is a address which is makred 'deprecated'. The commit mistakenly 
changed ifa->flags to ifa_result->flags (probably copy/paste error from a 
few lines above) in the 'Rule 3' address selection code.

The patch below restores the previous RFC-compliant behavior, please 
apply.

Cc: Jiri Bohac <jbohac@suse.cz>
Cc: Petr Baudis <pasky@suse.cz>
Signed-off-by: Jiri Kosina <jkosina@suse.cz>

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 91ef3be..45b4c82 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1021,7 +1021,7 @@ int ipv6_dev_get_saddr(struct net_device
 				hiscore.rule++;
 			}
 			if (ipv6_saddr_preferred(score.addr_type) ||
-			   (((ifa_result->flags &
+			   (((ifa->flags &
 			    (IFA_F_DEPRECATED|IFA_F_OPTIMISTIC)) == 0))) {
 				score.attrs |= IPV6_SADDR_SCORE_PREFERRED;
 				if (!(hiscore.attrs & IPV6_SADDR_SCORE_PREFERRED)) {
