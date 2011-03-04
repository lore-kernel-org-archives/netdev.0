From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH 1/4] mcast: net_device dev not used
Date: Fri,  4 Mar 2011 22:45:03 +0100
Message-ID: <1299275106-11513-1-git-send-email-hagen@jauu.net>
Cc: Hagen Paul Pfeifer <hagen@jauu.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:39155 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1759941Ab1CDVpJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2011 16:45:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip6_mc_source(), ip6_mc_msfilter() as well as ip6_mc_msfget() declare
and assign dev but do not use the variable afterwards.

Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
---
 net/ipv6/mcast.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 7b27d08..f2c9b69 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -319,7 +319,6 @@ int ip6_mc_source(int add, int omode, struct sock *sk,
 {
 	struct in6_addr *source, *group;
 	struct ipv6_mc_socklist *pmc;
-	struct net_device *dev;
 	struct inet6_dev *idev;
 	struct ipv6_pinfo *inet6 = inet6_sk(sk);
 	struct ip6_sf_socklist *psl;
@@ -341,7 +340,6 @@ int ip6_mc_source(int add, int omode, struct sock *sk,
 		rcu_read_unlock();
 		return -ENODEV;
 	}
-	dev = idev->dev;
 
 	err = -EADDRNOTAVAIL;
 
@@ -455,7 +453,6 @@ int ip6_mc_msfilter(struct sock *sk, struct group_filter *gsf)
 {
 	struct in6_addr *group;
 	struct ipv6_mc_socklist *pmc;
-	struct net_device *dev;
 	struct inet6_dev *idev;
 	struct ipv6_pinfo *inet6 = inet6_sk(sk);
 	struct ip6_sf_socklist *newpsl, *psl;
@@ -478,7 +475,6 @@ int ip6_mc_msfilter(struct sock *sk, struct group_filter *gsf)
 		rcu_read_unlock();
 		return -ENODEV;
 	}
-	dev = idev->dev;
 
 	err = 0;
 
@@ -549,7 +545,6 @@ int ip6_mc_msfget(struct sock *sk, struct group_filter *gsf,
 	struct in6_addr *group;
 	struct ipv6_mc_socklist *pmc;
 	struct inet6_dev *idev;
-	struct net_device *dev;
 	struct ipv6_pinfo *inet6 = inet6_sk(sk);
 	struct ip6_sf_socklist *psl;
 	struct net *net = sock_net(sk);
@@ -566,7 +561,6 @@ int ip6_mc_msfget(struct sock *sk, struct group_filter *gsf,
 		rcu_read_unlock();
 		return -ENODEV;
 	}
-	dev = idev->dev;
 
 	err = -EADDRNOTAVAIL;
 	/*
-- 
1.7.4.1.57.g0466.dirty

