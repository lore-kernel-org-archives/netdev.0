From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH iproute2/net-next 2/7] tc: flower: use correct type when calling flower_icmp_attr_type
Date: Thu,  2 Feb 2017 11:38:35 +0100
Message-ID: <1486031920-10784-3-git-send-email-simon.horman@netronome.com>
References: <1486031920-10784-1-git-send-email-simon.horman@netronome.com>
Cc: Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:37168 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751108AbdBBKiz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 05:38:55 -0500
Received: by mail-wm0-f41.google.com with SMTP id v77so81432035wmv.0
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 02:38:55 -0800 (PST)
In-Reply-To: <1486031920-10784-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use enum flower_icmp_field rather than bool as type of third parameter
when calling flower_icmp_attr_type.

Fixes: eb3b5696f163 ("tc: flower: support matching on ICMP type and code")
Signed-off-by: Simon Horman <simon.horman@netronome.com>
--
This should not have a run-time affect assuming both false and,
FLOWER_ICMP_FIELD_TYPE, first value of enum flower_icmp_field rather,
are zero.
---
 tc/f_flower.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/tc/f_flower.c b/tc/f_flower.c
index 7cb2cd45a783..0f2251315975 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -1061,10 +1061,12 @@ static int flower_print_opt(struct filter_util *qu, FILE *f,
 	if (nl_type >= 0)
 		flower_print_port(f, "src_port", tb[nl_type]);
 
-	nl_type = flower_icmp_attr_type(eth_type, ip_proto, false);
+	nl_type = flower_icmp_attr_type(eth_type, ip_proto,
+					FLOWER_ICMP_FIELD_TYPE);
 	if (nl_type >= 0)
 		flower_print_icmp(f, "icmp_type", tb[nl_type]);
-	nl_type = flower_icmp_attr_type(eth_type, ip_proto, true);
+	nl_type = flower_icmp_attr_type(eth_type, ip_proto,
+					FLOWER_ICMP_FIELD_CODE);
 	if (nl_type >= 0)
 		flower_print_icmp(f, "icmp_code", tb[nl_type]);
 
-- 
2.7.0.rc3.207.g0ac5344
