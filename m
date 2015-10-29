From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] iproute: fix filter_nlmsg
Date: Thu, 29 Oct 2015 12:15:47 +0100
Message-ID: <1446117347-9110-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:54544 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751089AbbJ2LPt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Oct 2015 07:15:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is based upon an old Fedora bug[1] regarding the routing
setup of PPP links. I'm not quite sure if it still applies today or how
to trigger it, but looking at the change introducing this, it's
obviously a bug.

[1] https://bugzilla.redhat.com/show_bug.cgi?id=622782

Fixes: 4479282 ("iproute2: filter routing entries based on clone flag")
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/iproute.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index eab512d..ea7e9aa 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -151,7 +151,7 @@ static int filter_nlmsg(struct nlmsghdr *n, struct rtattr **tb, int host_len)
 	if (r->rtm_family == AF_INET6 && table != RT_TABLE_MAIN)
 		ip6_multiple_tables = 1;
 
-	if (filter.cloned == !(r->rtm_flags&RTM_F_CLONED))
+	if (filter.cloned && !(r->rtm_flags&RTM_F_CLONED))
 		return 0;
 
 	if (r->rtm_family == AF_INET6 && !ip6_multiple_tables) {
-- 
2.1.2
