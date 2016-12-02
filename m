From: Simon Horman <simon.horman@netronome.com>
Subject: [[PATCH iproute2/net-next v2] 3/4] tc: flower: correct name of ip_proto parameter to flower_parse_port()
Date: Fri,  2 Dec 2016 09:45:20 +0100
Message-ID: <1480668321-20875-4-git-send-email-simon.horman@netronome.com>
References: <1480668321-20875-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f177.google.com ([209.85.210.177]:35937 "EHLO
        mail-wj0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758709AbcLBIpj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 03:45:39 -0500
Received: by mail-wj0-f177.google.com with SMTP id qp4so225995596wjc.3
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 00:45:38 -0800 (PST)
In-Reply-To: <1480668321-20875-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This corrects a typo.

Fixes: a1fb0d484237 ("tc: flower: Support matching on SCTP ports")
Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 tc/f_flower.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/tc/f_flower.c b/tc/f_flower.c
index dacf24faf00e..d86ccdc3d3f0 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -160,15 +160,15 @@ static int flower_parse_ip_addr(char *str, __be16 eth_type,
 	return 0;
 }
 
-static int flower_port_attr_type(__u8 ip_port, bool is_src)
+static int flower_port_attr_type(__u8 ip_proto, bool is_src)
 {
-	if (ip_port == IPPROTO_TCP) {
+	if (ip_proto == IPPROTO_TCP) {
 		return is_src ? TCA_FLOWER_KEY_TCP_SRC :
 			TCA_FLOWER_KEY_TCP_DST;
-	} else if (ip_port == IPPROTO_UDP) {
+	} else if (ip_proto == IPPROTO_UDP) {
 		return is_src ? TCA_FLOWER_KEY_UDP_SRC :
 			TCA_FLOWER_KEY_UDP_DST;
-	} else if (ip_port == IPPROTO_SCTP) {
+	} else if (ip_proto == IPPROTO_SCTP) {
 		return is_src ? TCA_FLOWER_KEY_SCTP_SRC :
 			TCA_FLOWER_KEY_SCTP_DST;
 	} else {
@@ -177,14 +177,14 @@ static int flower_port_attr_type(__u8 ip_port, bool is_src)
 	}
 }
 
-static int flower_parse_port(char *str, __u8 ip_port, bool is_src,
+static int flower_parse_port(char *str, __u8 ip_proto, bool is_src,
 			     struct nlmsghdr *n)
 {
 	int ret;
 	int type;
 	__be16 port;
 
-	type = flower_port_attr_type(ip_port, is_src);
+	type = flower_port_attr_type(ip_proto, is_src);
 	if (type < 0)
 		return -1;
 
-- 
2.7.0.rc3.207.g0ac5344
