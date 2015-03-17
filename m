From: David Ahern <dsahern@gmail.com>
Subject: [PATCH 3/3] iproute2: Add support for phys_port_name
Date: Mon, 16 Mar 2015 21:27:17 -0600
Message-ID: <1426562837-13126-3-git-send-email-dsahern@gmail.com>
References: <1426562837-13126-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>, Jiri Pirko <jiri@resnulli.us>,
	Scott Feldman <sfeldma@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:36544 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751292AbbCQD1j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 23:27:39 -0400
Received: by iegc3 with SMTP id c3so191753599ieg.3
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 20:27:39 -0700 (PDT)
In-Reply-To: <1426562837-13126-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Display phys_port_name attribute if returned:

./ip link show sw1p1
4: sw1p1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop port name sw1p1 state DOWN mode DEFAULT group default qlen 1000
    link/ether 52:54:00:12:35:01 brd ff:ff:ff:ff:ff:ff

Signed-off-by: David Ahern <dsahern@gmail.com>
Cc: Jiri Pirko <jiri@resnulli.us>
Cc: Scott Feldman <sfeldma@gmail.com>

---
 include/linux/if_link.h | 1 +
 ip/ipaddress.c          | 3 +++
 2 files changed, 4 insertions(+)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 3450c3fbdc65..c5ee8c91b1c6 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -147,6 +147,7 @@ enum {
 	IFLA_CARRIER_CHANGES,
 	IFLA_PHYS_SWITCH_ID,
 	IFLA_LINK_NETNSID,
+	IFLA_PHYS_PORT_NAME,
 	__IFLA_MAX
 };
 
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 99a6ab5977e3..9e65015b7a48 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -645,6 +645,9 @@ int print_linkinfo(const struct sockaddr_nl *who,
 				      b1, sizeof(b1)));
 	}
 
+	if (tb[IFLA_PHYS_PORT_NAME])
+		fprintf(fp, "port name %s ", rta_getattr_str(tb[IFLA_PHYS_PORT_NAME]));
+
 	if (tb[IFLA_OPERSTATE])
 		print_operstate(fp, rta_getattr_u8(tb[IFLA_OPERSTATE]));
 
-- 
2.2.1
