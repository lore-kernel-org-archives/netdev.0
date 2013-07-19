From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2] ip: show physical port id
Date: Fri, 19 Jul 2013 15:55:52 +0200
Message-ID: <1374242152-10325-5-git-send-email-jiri@resnulli.us>
References: <1374242152-10325-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, stephen@networkplumber.org,
	Narendra_K@Dell.com, bhutchings@solarflare.com,
	john.r.fastabend@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f176.google.com ([209.85.215.176]:63423 "EHLO
	mail-ea0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759542Ab3GSN4I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 09:56:08 -0400
Received: by mail-ea0-f176.google.com with SMTP id z15so2387372ead.7
        for <netdev@vger.kernel.org>; Fri, 19 Jul 2013 06:56:07 -0700 (PDT)
In-Reply-To: <1374242152-10325-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/if_link.h |  1 +
 ip/ipaddress.c          | 10 ++++++++++
 2 files changed, 11 insertions(+)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 965dc9f..ea0d5b7 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -143,6 +143,7 @@ enum {
 	IFLA_NUM_TX_QUEUES,
 	IFLA_NUM_RX_QUEUES,
 	IFLA_CARRIER,
+	IFLA_PHYS_PORT_ID,
 	__IFLA_MAX
 };
 
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 5b9a438..0c7c55b 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -429,6 +429,16 @@ int print_linkinfo(const struct sockaddr_nl *who,
 		fprintf(fp, "master %s ", ll_idx_n2a(*(int*)RTA_DATA(tb[IFLA_MASTER]), b1));
 	}
 
+	if (tb[IFLA_PHYS_PORT_ID]) {
+		int i;
+		unsigned char *buf = RTA_DATA(tb[IFLA_PHYS_PORT_ID]);
+		unsigned char len = RTA_PAYLOAD(tb[IFLA_PHYS_PORT_ID]);
+
+		fprintf(fp, "phys_port_id ");
+		for (i = 0; i < len; i++)
+			fprintf(fp, "%02x", buf[i]);
+		fprintf(fp, " ");
+	}
 	if (tb[IFLA_OPERSTATE])
 		print_operstate(fp, rta_getattr_u8(tb[IFLA_OPERSTATE]));
 
-- 
1.8.1.4
