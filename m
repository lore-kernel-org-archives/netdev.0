From: David Ahern <dsahern@gmail.com>
Subject: [PATCH 3/3] iproute2: Add support for phys_port_name
Date: Tue, 17 Mar 2015 09:30:58 -0600
Message-ID: <1426606258-13466-3-git-send-email-dsahern@gmail.com>
References: <1426606258-13466-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org, jiri@resnulli.us, sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:37038 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753459AbbCQPbU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 11:31:20 -0400
Received: by igcqo1 with SMTP id qo1so15346823igc.0
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2015 08:31:19 -0700 (PDT)
In-Reply-To: <1426606258-13466-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Display phys_port_name attribute if returned:

./ip link show sw1p1
4: sw1p1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop port name sw1p1 state DOWN mode DEFAULT group default qlen 1000
    link/ether 52:54:00:12:35:01 brd ff:ff:ff:ff:ff:ff

Signed-off-by: David Ahern <dsahern@gmail.com>
Acked-by: Jiri Pirko <jiri@resnulli.us>
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
