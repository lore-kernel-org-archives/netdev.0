From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2 3/3] iproute2: ipa: show port id
Date: Thu, 15 May 2014 15:10:22 +0200
Message-ID: <1400159422-11797-4-git-send-email-jiri@resnulli.us>
References: <1400159422-11797-1-git-send-email-jiri@resnulli.us>
Cc: stephen@networkplumber.org, mschmidt@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:45386 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752725AbaEONKi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 09:10:38 -0400
Received: by mail-lb0-f177.google.com with SMTP id s7so757330lbd.8
        for <netdev@vger.kernel.org>; Thu, 15 May 2014 06:10:37 -0700 (PDT)
In-Reply-To: <1400159422-11797-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 ip/ipaddress.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 32f930e..ce5e762 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -485,6 +485,14 @@ int print_linkinfo(const struct sockaddr_nl *who,
 		fprintf(fp, "master %s ", ll_idx_n2a(*(int*)RTA_DATA(tb[IFLA_MASTER]), b1));
 	}
 
+	if (tb[IFLA_PHYS_PORT_ID]) {
+		SPRINT_BUF(b1);
+		fprintf(fp, "portid %s ",
+			hexstring_n2a(RTA_DATA(tb[IFLA_PHYS_PORT_ID]),
+				      RTA_PAYLOAD(tb[IFLA_PHYS_PORT_ID]),
+				      b1, sizeof(b1)));
+	}
+
 	if (tb[IFLA_OPERSTATE])
 		print_operstate(fp, rta_getattr_u8(tb[IFLA_OPERSTATE]));
 
-- 
1.9.0
