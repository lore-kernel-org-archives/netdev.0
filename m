From: Nikolay Kopitonenko <Nikolay.Kopitonenko@yourserveradmin.com>
Subject: PATCH  to bug #8876
Date: Fri, 07 Sep 2007 17:46:40 +0300
Message-ID: <46E16450.6050608@yourserveradmin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tetrahedron.itechcraft.com ([72.34.45.195]:35803 "EHLO
	tetrahedron.itechcraft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932757AbXIGQE5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2007 12:04:57 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi there!

Below is a fix for this:
http://bugzilla.kernel.org/show_bug.cgi?id=8876


Applies to any version since 2.6.22 to latest: 2.6.23-rc5-git1

please apply :)


-------------------------CUT---------------------
diff -urN a/net/ipv4/devinet.c b/net/ipv4/devinet.c
--- a/net/ipv4/devinet.c	2007-07-09 02:32:17.000000000 +0300
+++ b/net/ipv4/devinet.c	2007-08-10 20:33:22.000000000 +0300
@@ -1193,7 +1193,7 @@
 		for (ifa = in_dev->ifa_list, ip_idx = 0; ifa;
 		     ifa = ifa->ifa_next, ip_idx++) {
 			if (ip_idx < s_ip_idx)
-				goto cont;
+				continue;
 			if (inet_fill_ifaddr(skb, ifa, NETLINK_CB(cb->skb).pid,
 					     cb->nlh->nlmsg_seq,
 					     RTM_NEWADDR, NLM_F_MULTI) <= 0)
-------------------------/CUT---------------------

Signed-off-by: Nikolay.Kopitonenko@yourserveradmin.com


Thanks

Nikolay Kopitonenko
