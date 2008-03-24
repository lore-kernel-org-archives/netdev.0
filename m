From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 11/11 net-2.6.25] [NETNS]: Enable TCP/UDP/ICMP inside namespace.
Date: Mon, 24 Mar 2008 17:36:12 +0300
Message-ID: <1206369372-27711-11-git-send-email-den@openvz.org>
References: <1206369185.23705.7.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, devel@openvz.org,
	containers@lists.osdl.org, xemul@openvz.org,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:50994 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758661AbYCXOfv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Mar 2008 10:35:51 -0400
In-Reply-To: <1206369185.23705.7.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/af_inet.c |    3 +++
 net/ipv4/udplite.c |    1 +
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 39ddb84..06cfb0b 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1302,17 +1302,20 @@ static struct net_protocol tcp_protocol = {
 	.gso_send_check = tcp_v4_gso_send_check,
 	.gso_segment =	tcp_tso_segment,
 	.no_policy =	1,
+	.netns_ok =	1,
 };
 
 static struct net_protocol udp_protocol = {
 	.handler =	udp_rcv,
 	.err_handler =	udp_err,
 	.no_policy =	1,
+	.netns_ok =	1,
 };
 
 static struct net_protocol icmp_protocol = {
 	.handler =	icmp_rcv,
 	.no_policy =	1,
+	.netns_ok =	1,
 };
 
 static int __init init_ipv4_mibs(void)
diff --git a/net/ipv4/udplite.c b/net/ipv4/udplite.c
index 8d42e34..e61ab2b 100644
--- a/net/ipv4/udplite.c
+++ b/net/ipv4/udplite.c
@@ -31,6 +31,7 @@ static	struct net_protocol udplite_protocol = {
 	.handler	= udplite_rcv,
 	.err_handler	= udplite_err,
 	.no_policy	= 1,
+	.netns_ok	= 1,
 };
 
 DEFINE_PROTO_INUSE(udplite)
-- 
1.5.3.rc5

