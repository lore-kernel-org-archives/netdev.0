From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH v4 net-next 05/11] net: Add full IPv6 addresses to
 flow_keys
Date: Fri, 22 May 2015 09:57:38 +0200
Message-ID: <20150522075738.GE2138@nanopsycho.orion>
References: <1432253506-3646977-1-git-send-email-tom@herbertland.com>
 <1432253506-3646977-6-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:38145 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755929AbbEVH5l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 03:57:41 -0400
Received: by wichy4 with SMTP id hy4so38485647wic.1
        for <netdev@vger.kernel.org>; Fri, 22 May 2015 00:57:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1432253506-3646977-6-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, May 22, 2015 at 02:11:40AM CEST, tom@herbertland.com wrote:
>This patch adds full IPv6 addresses into flow_keys and uses them as
>input to the flow hash function. The implementation supports either
>IPv4 or IPv6 addresses in a union, and selector is used to determine
>how may words to input to jhash2.
>
>We also add flow_get_u32_dst and flow_get_u32_src functions which are
>used to get a u32 representation of the source and destination
>addresses. For IPv6, ipv6_addr_hash is called. These functions retain
>getting the legacy values of src and dst in flow_keys.
>
>With this patch, Ethertype and IP protocol are now included in the
>flow hash input.
>
>Signed-off-by: Tom Herbert <tom@herbertland.com>

...

>diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
>index cba6a10..306d461 100644
>--- a/include/net/flow_dissector.h
>+++ b/include/net/flow_dissector.h
>@@ -12,7 +12,7 @@
>  */
> struct flow_dissector_key_control {
> 	u16	thoff;
>-	u16	padding;
>+	u16	addr_type;


I don't understand why this is needed. I don't like this. You assign enum
flow_dissector_key_id to this. Why not just continue to use
key->basic.n_proto?
