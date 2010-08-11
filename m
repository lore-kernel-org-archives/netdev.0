From: Ben Greear <greearb@candelatech.com>
Subject: [iproute2] iproute2:  Fix 'addr flush secondary' logic.
Date: Wed, 11 Aug 2010 10:19:42 -0700
Message-ID: <1281547182-1252-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:49574 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752537Ab0HKRTp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Aug 2010 13:19:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It appears that the check for secondary v/s primary was reversed
when flushing addresses.  This caused:
ip addr flush dev eth0 secondary
to not actually flush anything.

This patch makes the check for IFA_F_SECONDARY match the
function names.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 5f0789c... 77b400d... M	ip/ipaddress.c
 ip/ipaddress.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 5f0789c..77b400d 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -637,7 +637,7 @@ int print_addrinfo_primary(const struct sockaddr_nl *who, struct nlmsghdr *n,
 {
 	struct ifaddrmsg *ifa = NLMSG_DATA(n);
 
-	if (!ifa->ifa_flags & IFA_F_SECONDARY)
+	if (ifa->ifa_flags & IFA_F_SECONDARY)
 		return 0;
 
 	return print_addrinfo(who, n, arg);
@@ -648,7 +648,7 @@ int print_addrinfo_secondary(const struct sockaddr_nl *who, struct nlmsghdr *n,
 {
 	struct ifaddrmsg *ifa = NLMSG_DATA(n);
 
-	if (ifa->ifa_flags & IFA_F_SECONDARY)
+	if (!ifa->ifa_flags & IFA_F_SECONDARY)
 		return 0;
 
 	return print_addrinfo(who, n, arg);
-- 
1.6.2.5

