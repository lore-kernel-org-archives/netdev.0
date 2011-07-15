From: Dan McGee <dan@archlinux.org>
Subject: [PATCH] ip route: don't implicitly filter address family
Date: Fri, 15 Jul 2011 13:38:33 -0500
Message-ID: <1310755113-32492-1-git-send-email-dan@archlinux.org>
Cc: Dan McGee <dan@archlinux.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:37763 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753604Ab1GOSih (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2011 14:38:37 -0400
Received: by gxk21 with SMTP id 21so655778gxk.19
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2011 11:38:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When looking at the output of 'ip route show' on an IPv6 capable
machine, the default output doesn't show IPv6 routes. This is unlike any
other ip subcommand, which show all address families by default.
Furthermore, the behavior is totally bogus for different permutations of
the command:

    ip route show : will show IPv4, not show IPv6
	ip route show table all : will show IPv4 and IPv6
	ip route -f link show : will show IPv4 and IPv6

Rectify this behavior by removing some 2004 code that tries to munge the
address family if it is unspecified and fails bad at guessing the user's
intention.

Signed-off-by: Dan McGee <dan@archlinux.org>
---
 ip/iproute.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index ca09029..4458d9c 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -1236,9 +1236,6 @@ static int iproute_list_flush_or_save(int argc, char **argv, int action)
 		argc--; argv++;
 	}
 
-	if (do_ipv6 == AF_UNSPEC && filter.tb)
-		do_ipv6 = AF_INET;
-
 	ll_init_map(&rth);
 
 	if (id || od)  {
-- 
1.7.6

