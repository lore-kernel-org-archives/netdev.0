From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [RFC net-next] ipv6: ext_header: add function to handle RPL
 extension header option 0x63
Date: Thu, 4 May 2017 18:00:42 +0200
Message-ID: <20170504160042.GB2385@nanopsycho>
References: <dca567582f1979384fb1f3c3d1411349@ceid.upatras.gr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, linux-wpan@vger.kernel.org,
        Michael Richardson <mcr@sandelman.ca>,
        Unstrung Hackers <unstrung-hackers@lists.sandelman.ca>,
        netdev-owner@vger.kernel.org, linux-bluetooth@vger.kernel.org
To: Andreas Bardoutsos <bardoutsos@ceid.upatras.gr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:35482 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754649AbdEDQAq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 12:00:46 -0400
Received: by mail-wr0-f194.google.com with SMTP id g12so1891890wrg.2
        for <netdev@vger.kernel.org>; Thu, 04 May 2017 09:00:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <dca567582f1979384fb1f3c3d1411349@ceid.upatras.gr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, May 04, 2017 at 05:17:18PM CEST, bardoutsos@ceid.upatras.gr wrote:
>Signed-off-by: Andreas Bardoutsos <bardoutsos@ceid.upatras.gr>
>---
>Hi all!
>
>I have added a dump function(always return true) to recognise RPL extension
>header(RFC6553)
>Otherwise packet was dropped by kernel resulting in failing communication in
>RPL DAG's between
>linux running border routers and devices in the graph.For example
>communication
>with contiki OS running devices was previously impossible.
>
> include/uapi/linux/in6.h |  1 +
> net/ipv6/exthdrs.c       | 13 +++++++++++++
> 2 files changed, 14 insertions(+)
>
>diff --git a/include/uapi/linux/in6.h b/include/uapi/linux/in6.h
>index 46444f8fbee4..5cc12d309dfe 100644
>--- a/include/uapi/linux/in6.h
>+++ b/include/uapi/linux/in6.h
>@@ -146,6 +146,7 @@ struct in6_flowlabel_req {
> #define IPV6_TLV_CALIPSO	7	/* RFC 5570 */
> #define IPV6_TLV_JUMBO		194
> #define IPV6_TLV_HAO		201	/* home address option */
>+#define IPV6_TLV_RPL	99	/* RFC 6553 */
>
> /*
>  *	IPV6 socket options
>diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
>index b636f1da9aec..82ed60d3180e 100644
>--- a/net/ipv6/exthdrs.c
>+++ b/net/ipv6/exthdrs.c
>@@ -785,6 +785,15 @@ static bool ipv6_hop_calipso(struct sk_buff *skb, int
>optoff)
> 	return false;
> }
>
>+/* RPL RFC 6553 */
>+
>+static bool ipv6_hop_rpl(struct sk_buff *skb, int optoff)
>+{
>+	/*Dump function which always return true
>+	*when rpl option is detected*/

This is definitelly wrong formatting of comment. Did you run checkpatch?


>+	return true;
>+}
>+
> static const struct tlvtype_proc tlvprochopopt_lst[] = {
> 	{
> 		.type	= IPV6_TLV_ROUTERALERT,
>@@ -798,6 +807,10 @@ static const struct tlvtype_proc tlvprochopopt_lst[] = {
> 		.type	= IPV6_TLV_CALIPSO,
> 		.func	= ipv6_hop_calipso,
> 	},
>+	{
>+		.type	= IPV6_TLV_RPL,
>+		.func	= ipv6_hop_rpl,
>+	},
> 	{ -1, }
> };
>
