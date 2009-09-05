From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH] ipv6: Add IFA_F_DADFAILED flag
Date: Fri, 04 Sep 2009 21:38:07 -0400
Message-ID: <4AA1C0FF.4030109@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: david Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:40956 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934291AbZIEBiH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2009 21:38:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Note: if this is accepted I'll send out a patch for iproute,
 if you'd prefer to not use the last ifa_flag I'll send a
 much larger patch that does this differently :) ]


Add IFA_F_DADFAILED flag to denote an IPv6 address that has
failed Duplicate Address Detection, that way tools like
/sbin/ip can be more informative.

3: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000
    inet6 2001:db8::1/64 scope global tentative dadfailed 
       valid_lft forever preferred_lft forever

Signed-off-by: Brian Haley <brian.haley@hp.com>
---

diff --git a/include/linux/if_addr.h b/include/linux/if_addr.h
index a60c821..fd97404 100644
--- a/include/linux/if_addr.h
+++ b/include/linux/if_addr.h
@@ -41,6 +41,7 @@ enum
 
 #define	IFA_F_NODAD		0x02
 #define IFA_F_OPTIMISTIC	0x04
+#define IFA_F_DADFAILED		0x08
 #define	IFA_F_HOMEADDRESS	0x10
 #define IFA_F_DEPRECATED	0x20
 #define IFA_F_TENTATIVE		0x40
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 43b3c9f..6532966 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1376,7 +1376,7 @@ static void addrconf_dad_stop(struct inet6_ifaddr *ifp)
 	if (ifp->flags&IFA_F_PERMANENT) {
 		spin_lock_bh(&ifp->lock);
 		addrconf_del_timer(ifp);
-		ifp->flags |= IFA_F_TENTATIVE;
+		ifp->flags |= IFA_F_DADFAILED;
 		spin_unlock_bh(&ifp->lock);
 		in6_ifa_put(ifp);
 #ifdef CONFIG_IPV6_PRIVACY
