From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2 v2] iplink: display the value of IFLA_PROMISCUITY
Date: Tue,  5 Feb 2013 09:28:01 +0100
Message-ID: <1360052881-17935-1-git-send-email-nicolas.dichtel@6wind.com>
References: <20130204095636.64b57bd0@nehalam.linuxnetplumber.net>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:37505 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754117Ab3BEIid (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2013 03:38:33 -0500
In-Reply-To: <20130204095636.64b57bd0@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is useful to know the 'real' status of an interface (the flag IFF_PROMISC
is exported by the kernel only when the user set it explicitly, for example it
will not be exported when a tcpdump is running).

This information will be displayed when '-details' is provided by the user.

Example:
$ ip -d l l tun10
6: tun10: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 1480 qdisc noqueue state UNKNOWN mode DEFAULT
    link/sit 10.16.0.249 peer 10.16.0.121
    sit remote 10.16.0.121 local 10.16.0.249 ttl inherit pmtudisc 6rd-prefix 2002::/16
    promiscuity 2

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
v2: because IFLA_PROMISCUITY is read only, display it only when '-details' is
    provided (and even if the value is zero)

 ip/ipaddress.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 2eb1a0a..e8cab40 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -464,6 +464,10 @@ int print_linkinfo(const struct sockaddr_nl *who,
 	if (do_link && tb[IFLA_LINKINFO] && show_details)
 		print_linktype(fp, tb[IFLA_LINKINFO]);
 
+	if (do_link && tb[IFLA_PROMISCUITY] && show_details)
+		fprintf(fp, "\n    promiscuity %u ",
+			*(int*)RTA_DATA(tb[IFLA_PROMISCUITY]));
+
 	if (do_link && tb[IFLA_IFALIAS])
 		fprintf(fp,"\n    alias %s", 
 			rta_getattr_str(tb[IFLA_IFALIAS]));
-- 
1.8.0.1
