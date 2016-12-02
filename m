From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH/RFC iproute2/net-next 2/3] tc: flower: introduce enum
 flower_endpoint
Date: Fri, 2 Dec 2016 18:08:42 +0100
Message-ID: <20161202170842.GB1883@nanopsycho.orion>
References: <1480672785-14570-1-git-send-email-simon.horman@netronome.com>
 <1480672785-14570-3-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@mellanox.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f195.google.com ([209.85.210.195]:33302 "EHLO
        mail-wj0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752053AbcLBRIr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 12:08:47 -0500
Received: by mail-wj0-f195.google.com with SMTP id kp2so31022454wjc.0
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 09:08:46 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1480672785-14570-3-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Dec 02, 2016 at 10:59:44AM CET, simon.horman@netronome.com wrote:
>Introduce enum flower_endpoint and use it instead of a bool
>as the type for paramatising source and destination.
>
>This is intended to improve read-ability and provide some type
>checking of endpoint parameters.
>
>Signed-off-by: Simon Horman <simon.horman@netronome.com>
>---
> tc/f_flower.c | 22 ++++++++++++++--------
> 1 file changed, 14 insertions(+), 8 deletions(-)
>
>diff --git a/tc/f_flower.c b/tc/f_flower.c
>index 615e8f27bed2..42253067b43d 100644
>--- a/tc/f_flower.c
>+++ b/tc/f_flower.c
>@@ -23,6 +23,11 @@
> #include "tc_util.h"
> #include "rt_names.h"
> 
>+enum flower_endpoint {
>+	flower_src,
>+	flower_dst

	FLOWER_ENDPOINT_SRC,
	FLOWER_ENDPOINT_DST,

>+};
>+
> static void explain(void)
> {
> 	fprintf(stderr,
>@@ -160,29 +165,30 @@ static int flower_parse_ip_addr(char *str, __be16 eth_type,
> 	return 0;
> }
> 
>-static int flower_port_attr_type(__u8 ip_proto, bool is_src)
>+static int flower_port_attr_type(__u8 ip_proto, enum flower_endpoint endpoint)
> {
> 	if (ip_proto == IPPROTO_TCP)
>-		return is_src ? TCA_FLOWER_KEY_TCP_SRC :
>+		return endpoint == flower_src ? TCA_FLOWER_KEY_TCP_SRC :
> 			TCA_FLOWER_KEY_TCP_DST;
> 	else if (ip_proto == IPPROTO_UDP)
>-		return is_src ? TCA_FLOWER_KEY_UDP_SRC :
>+		return endpoint == flower_src ? TCA_FLOWER_KEY_UDP_SRC :
> 			TCA_FLOWER_KEY_UDP_DST;
> 	else if (ip_proto == IPPROTO_SCTP)
>-		return is_src ? TCA_FLOWER_KEY_SCTP_SRC :
>+		return endpoint == flower_src ? TCA_FLOWER_KEY_SCTP_SRC :
> 			TCA_FLOWER_KEY_SCTP_DST;
> 	else
> 		return -1;
> }
> 
>-static int flower_parse_port(char *str, __u8 ip_proto, bool is_src,
>+static int flower_parse_port(char *str, __u8 ip_proto,
>+			     enum flower_endpoint endpoint,
> 			     struct nlmsghdr *n)
> {
> 	int ret;
> 	int type;
> 	__be16 port;
> 
>-	type = flower_port_attr_type(ip_proto, is_src);
>+	type = flower_port_attr_type(ip_proto, endpoint);
> 	if (type < 0)
> 		return -1;
> 
>@@ -340,14 +346,14 @@ static int flower_parse_opt(struct filter_util *qu, char *handle,
> 			}
> 		} else if (matches(*argv, "dst_port") == 0) {
> 			NEXT_ARG();
>-			ret = flower_parse_port(*argv, ip_proto, false, n);
>+			ret = flower_parse_port(*argv, ip_proto, flower_dst, n);
> 			if (ret < 0) {
> 				fprintf(stderr, "Illegal \"dst_port\"\n");
> 				return -1;
> 			}
> 		} else if (matches(*argv, "src_port") == 0) {
> 			NEXT_ARG();
>-			ret = flower_parse_port(*argv, ip_proto, true, n);
>+			ret = flower_parse_port(*argv, ip_proto, flower_src, n);
> 			if (ret < 0) {
> 				fprintf(stderr, "Illegal \"src_port\"\n");
> 				return -1;
>-- 
>2.7.0.rc3.207.g0ac5344
>
