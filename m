From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2 net-next 0/6] flow_dissector: Protocol specific flow dissector offload
Date: Wed, 30 Aug 2017 10:41:10 +0200
Message-ID: <874lsp8n2x.fsf@stressinduktion.org>
References: <20170829232711.1465-1-tom@quantonium.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <tom@quantonium.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:40947 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751263AbdH3IlN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 04:41:13 -0400
In-Reply-To: <20170829232711.1465-1-tom@quantonium.net> (Tom Herbert's message
        of "Tue, 29 Aug 2017 16:27:05 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Tom,

Tom Herbert <tom@quantonium.net> writes:

> This patch set adds a new offload type to perform flow dissection for
> specific protocols (either by EtherType or by IP protocol). This is
> primary useful to crack open UDP encapsulations (like VXLAN, GUE) for
> the purposes of parsing the encapsulated packet.
>
> Items in this patch set:
> - Constify skb argument to UDP lookup functions
> - Create new protocol case in __skb_dissect for ETH_P_TEB. This is based
>   on the code in the GRE dissect function and the special handling in
>   GRE can now be removed (it sets protocol to ETH_P_TEB and returns so
>   goto proto_again is done)
> - Add infrastructure for protocol specific flow dissection offload
> - Add infrastructure to perform UDP flow dissection. Uses same model of
>   GRO where a flow_dissect callback can be associated with a UDP
>   socket
> - Use the infrastructure to support flow dissection of VXLAN and GUE
>
> Tested:
>
> Forced RPS to call flow dissection for VXLAN, FOU, and GUE. Observed
> that inner packet was being properly dissected.
>
> v2: Add signed off

[...]

Can you provide more context on why you did this series? Is the entropy
insufficient you receive via UDP source ports? I assume this is the case
for HW RSS hashing but actually not for the software dissector.

Btw. we forbid hardware to use L4 information if IP_PROTO is UDP but we
allow it in RPS (not in IPv6 if flowlabel is present). Your series could
solve this problem by being more protocol specific and disallow
fragmentation on a particular quadtuple, very much the same like hw
encap offload, where we tell the specific port number to the hardware
and then disallow using L4 information for all other UDP protocols.

Thanks,
Hannes
