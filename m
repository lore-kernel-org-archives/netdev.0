From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH v4 net-next 06/11] net: Add keys for TIPC address
Date: Fri, 22 May 2015 10:05:18 +0200
Message-ID: <20150522080518.GF2138@nanopsycho.orion>
References: <1432253506-3646977-1-git-send-email-tom@herbertland.com>
 <1432253506-3646977-7-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:35693 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756315AbbEVIFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 04:05:21 -0400
Received: by wgfl8 with SMTP id l8so10083054wgf.2
        for <netdev@vger.kernel.org>; Fri, 22 May 2015 01:05:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1432253506-3646977-7-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, May 22, 2015 at 02:11:41AM CEST, tom@herbertland.com wrote:
>Add a new flow key for TIPC addresses.
>
>Signed-off-by: Tom Herbert <tom@herbertland.com>
>---
> include/net/flow_dissector.h | 10 ++++++++++
> net/core/flow_dissector.c    | 20 ++++++++++++++------
> 2 files changed, 24 insertions(+), 6 deletions(-)
>
>diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
>index 306d461..3ee606a 100644
>--- a/include/net/flow_dissector.h
>+++ b/include/net/flow_dissector.h
>@@ -50,6 +50,14 @@ struct flow_dissector_key_ipv6_addrs {
> };
> 
> /**
>+ * struct flow_dissector_key_tipc_addrs:
>+ * @srcnode: source node address
>+ */
>+struct flow_dissector_key_tipc_addrs {
>+	__be32 srcnode;
>+};
>+
>+/**
>  * struct flow_dissector_key_addrs:
>  * @v4addrs: IPv4 addresses
>  * @v6addrs: IPv6 addresses
>@@ -58,6 +66,7 @@ struct flow_dissector_key_addrs {
> 	union {
> 		struct flow_dissector_key_ipv4_addrs v4addrs;
> 		struct flow_dissector_key_ipv6_addrs v6addrs;
>+		struct flow_dissector_key_tipc_addrs tipcaddrs;
> 	};
> };
> 
>@@ -97,6 +106,7 @@ enum flow_dissector_key_id {
> 	FLOW_DISSECTOR_KEY_IPV6_HASH_ADDRS, /* struct flow_dissector_key_addrs */
> 	FLOW_DISSECTOR_KEY_PORTS, /* struct flow_dissector_key_ports */
> 	FLOW_DISSECTOR_KEY_ETH_ADDRS, /* struct flow_dissector_key_eth_addrs */
>+	FLOW_DISSECTOR_KEY_TIPC_ADDRS, /* struct flow_dissector_key_tipc_addrs */
> 
> 	FLOW_DISSECTOR_KEY_MAX,
> };
>diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
>index d77619f..8d6f089 100644
>--- a/net/core/flow_dissector.c
>+++ b/net/core/flow_dissector.c
>@@ -294,13 +294,12 @@ flow_label:
> 		key_control->thoff = (u16)nhoff;
> 
> 		if (skb_flow_dissector_uses_key(flow_dissector,
>-						FLOW_DISSECTOR_KEY_IPV6_HASH_ADDRS)) {
>+				FLOW_DISSECTOR_KEY_TIPC_ADDRS)) {
> 			key_addrs = skb_flow_dissector_target(flow_dissector,
>-							      FLOW_DISSECTOR_KEY_IPV6_HASH_ADDRS,
>-							      target_container);
>-			key_addrs->v4addrs.src = hdr->srcnode;
>-			key_addrs->v4addrs.dst = 0;
>-			key_control->addr_type = FLOW_DISSECTOR_KEY_IPV4_ADDRS;
>+				FLOW_DISSECTOR_KEY_TIPC_ADDRS,
>+				target_container);
>+			key_addrs->tipcaddrs.srcnode = hdr->srcnode;
>+			key_control->addr_type = FLOW_DISSECTOR_KEY_TIPC_ADDRS;


This patch looks good to me, leaving the addr_type part I mentioned in my
previous reply aside.
