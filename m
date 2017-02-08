From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH iproute2/net-next repost] tc: flower: use correct type when calling flower_icmp_attr_type
Date: Wed,  8 Feb 2017 12:34:47 +0100
Message-ID: <1486553687-14652-1-git-send-email-simon.horman@netronome.com>
Cc: Jiri Pirko <jiri@resnulli.us>,
        Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:33808 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753599AbdBHMET (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 07:04:19 -0500
Received: by mail-wm0-f41.google.com with SMTP id 196so49848240wmm.1
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 04:04:03 -0800 (PST)
Received: from penelope.horms.nl ([217.111.208.18])
        by smtp.gmail.com with ESMTPSA id 8sm8954345wmg.1.2017.02.08.03.55.03
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Feb 2017 03:55:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use enum flower_icmp_field rather than bool as type of third parameter
when calling flower_icmp_attr_type.

Fixes: eb3b5696f163 ("tc: flower: support matching on ICMP type and code")
Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
* Reposted after breaking out of a larger patch-set
* This should not have a run-time affect assuming both false and
  FLOWER_ICMP_FIELD_TYPE - the first value of enum flower_icmp_field -
  are zero.
---
 tc/f_flower.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/tc/f_flower.c b/tc/f_flower.c
index 403100c92af0..c9d56211b040 100644
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
