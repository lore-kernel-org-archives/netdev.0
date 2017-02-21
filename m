From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH/RFC net-next 1/2] flow dissector: ND support
Date: Tue, 21 Feb 2017 16:28:10 +0100
Message-ID: <20170221152810.GE2694@nanopsycho.mtl.com>
References: <1486031855-10551-1-git-send-email-simon.horman@netronome.com>
 <1486031855-10551-2-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:35564 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751140AbdBUP2N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 10:28:13 -0500
Received: by mail-wm0-f46.google.com with SMTP id v186so114168950wmd.0
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 07:28:13 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1486031855-10551-2-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Feb 02, 2017 at 11:37:34AM CET, simon.horman@netronome.com wrote:
>Allow dissection of Neighbour Discovery target IP, and source and
>destination link-layer addresses for neighbour solicitation and
>advertisement messages.
>
>Signed-off-by: Simon Horman <simon.horman@netronome.com>
>---

[...]

>@@ -633,6 +702,18 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
> 						     FLOW_DISSECTOR_KEY_ICMP,
> 						     target_container);
> 		key_icmp->icmp = skb_flow_get_be16(skb, nhoff, data, hlen);
>+
>+		if (dissector_uses_key(flow_dissector, FLOW_DISSECTOR_KEY_ND) &&
>+		    ip_proto == IPPROTO_IPV6 && key_icmp->code == 0 &&

IPPROTO_IPV6 say "IPv6-in-IPv4 tunnelling". Please use "NEXTHDR_IPV6"
instead.


>+		    (key_icmp->type == NDISC_NEIGHBOUR_SOLICITATION ||
>+		     key_icmp->type == NDISC_NEIGHBOUR_ADVERTISEMENT)) {
>+			key_nd = skb_flow_dissector_target(flow_dissector,
>+							   FLOW_DISSECTOR_KEY_ND,
>+							   target_container);
>+			if (!(skb_flow_dissect_nd(skb, key_nd, data, nhoff,
>+						  hlen, ipv6_payload_len)))
>+				goto out_bad;
>+		}

You should put this under "switch (ip_proto) {"
