From: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
Subject: [PATCH net-next] IPv6: add a function to check for a valid anycast source address
Date: Mon, 13 Jan 2014 17:44:22 +0100
Message-ID: <1389631462-4289-1-git-send-email-fx.lebail@yahoo.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Francois-Xavier Le Bail <fx.lebail@yahoo.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp06.smtpout.orange.fr ([80.12.242.128]:55673 "EHLO
	smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754861AbaAMRD1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 12:03:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Add ipv6_chk_acast_addr_src() to check if an anycast address is link-local
  on given interface or is global (on any interface).

Signed-off-by: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
---
 include/net/addrconf.h |    5 +++--
 net/ipv6/anycast.c     |   11 +++++++++++
 2 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 66c4a44..50e39a8 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -205,8 +205,9 @@ void ipv6_sock_ac_close(struct sock *sk);
 int ipv6_dev_ac_inc(struct net_device *dev, const struct in6_addr *addr);
 int __ipv6_dev_ac_dec(struct inet6_dev *idev, const struct in6_addr *addr);
 bool ipv6_chk_acast_addr(struct net *net, struct net_device *dev,
-				const struct in6_addr *addr);
-
+			 const struct in6_addr *addr);
+bool ipv6_chk_acast_addr_src(struct net *net, struct net_device *dev,
+			     const struct in6_addr *addr);
 
 /* Device notifier */
 int register_inet6addr_notifier(struct notifier_block *nb);
diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
index 5a80f15..4f2c62a 100644
--- a/net/ipv6/anycast.c
+++ b/net/ipv6/anycast.c
@@ -383,6 +383,17 @@ bool ipv6_chk_acast_addr(struct net *net, struct net_device *dev,
 	return found;
 }
 
+/*	check if address is link-local on given interface
+ *	or is global (on any interface)
+ */
+bool ipv6_chk_acast_addr_src(struct net *net, struct net_device *dev,
+			     const struct in6_addr *addr)
+{
+	if (ipv6_addr_type(addr) & IPV6_ADDR_LINKLOCAL)
+		return ipv6_chk_acast_dev(dev, addr);
+	else
+		return ipv6_chk_acast_addr(net, NULL, addr);
+}
 
 #ifdef CONFIG_PROC_FS
 struct ac6_iter_state {
