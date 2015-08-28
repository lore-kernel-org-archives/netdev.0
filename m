From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH v2 net-next 3/4] fou: reject IPv6 config
Date: Fri, 28 Aug 2015 20:48:21 +0200
Message-ID: <e43a28ab8a6c5d0f16476bc9102cb11478fa5eff.1440787601.git.jbenc@redhat.com>
References: <cover.1440787600.git.jbenc@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>, Pravin Shelar <pshelar@nicira.com>,
	Tom Herbert <tom@herbertland.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36755 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752609AbbH1St0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Aug 2015 14:49:26 -0400
In-Reply-To: <cover.1440787600.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fou does not really support IPv6 encapsulation. After an UDP socket is
created in fou_create, the encap_rcv callback is set either to fou_udp_recv
or to gue_udp_recv. Both of those unconditionally assume that the received
packet has an IPv4 header and access the data at network_header as it was an
IPv4 header. This leads to IPv6 flow label being interpreted as IP packet
length, etc.

Disallow fou tunnel to be configured as IPv6 until real IPv6 support is
added to fou.

CC: Tom Herbert <tom@herbertland.com>
Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
v2: no change
---
 net/ipv4/fou.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index 2d1646cff057..e0fcbbbcfe54 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -566,7 +566,7 @@ static int parse_nl_config(struct genl_info *info,
 	if (info->attrs[FOU_ATTR_AF]) {
 		u8 family = nla_get_u8(info->attrs[FOU_ATTR_AF]);
 
-		if (family != AF_INET && family != AF_INET6)
+		if (family != AF_INET)
 			return -EINVAL;
 
 		cfg->udp_config.family = family;
-- 
1.8.3.1
