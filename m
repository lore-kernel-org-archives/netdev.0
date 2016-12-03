From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH iproute2/net-next v3 2/3] tc: flower: correct name of ip_proto parameter to flower_parse_port()
Date: Sat,  3 Dec 2016 09:52:39 +0100
Message-ID: <1480755160-27768-3-git-send-email-simon.horman@netronome.com>
References: <1480755160-27768-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:34486 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751951AbcLCIxA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 03:53:00 -0500
Received: by mail-wm0-f49.google.com with SMTP id u144so7781067wmu.1
        for <netdev@vger.kernel.org>; Sat, 03 Dec 2016 00:52:53 -0800 (PST)
In-Reply-To: <1480755160-27768-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This corrects a typo.

Fixes: a1fb0d484237 ("tc: flower: Support matching on SCTP ports")
Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 tc/f_flower.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/tc/f_flower.c b/tc/f_flower.c
index f04c594d06ae..d2e8d0462dde 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -166,15 +166,15 @@ static int flower_parse_ip_addr(char *str, __be16 eth_type,
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
@@ -183,14 +183,14 @@ static int flower_port_attr_type(__u8 ip_port, bool is_src)
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
