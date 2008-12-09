From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: [RFC][PATCH 3/3]ipv6:fix the outgoing interface selection order in
 udpv6_sendmsg()
Date: Tue, 09 Dec 2008 15:12:59 +0800
Message-ID: <493E1A7B.9070208@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58381 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751949AbYLIHL2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2008 02:11:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1.When no interface is specified in an IPV6_PKTINFO ancillary data
  item, the interface specified in an IPV6_PKTINFO sticky optionis 
  is used.

RFC3542:
6.7.  Summary of Outgoing Interface Selection

   This document and [RFC-3493] specify various methods that affect the
   selection of the packet's outgoing interface.  This subsection
   summarizes the ordering among those in order to ensure deterministic
   behavior.

   For a given outgoing packet on a given socket, the outgoing interface
   is determined in the following order:

   1. if an interface is specified in an IPV6_PKTINFO ancillary data
      item, the interface is used.

   2. otherwise, if an interface is specified in an IPV6_PKTINFO sticky
      option, the interface is used.

Signed-off-by: Yang Hongyang<yanghy@cn.fujitsu.com>
---
 net/ipv6/udp.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 8b48512..addd856 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -761,6 +761,9 @@ do_udp_sendmsg:
 	}
 
 	if (!fl.oif)
+		fl.oif = np->sticky_pktinfo.ipi6_ifindex;
+
+	if (!fl.oif)
 		fl.oif = sk->sk_bound_dev_if;
 
 	if (msg->msg_controllen) {
-- 
1.6.0.1
