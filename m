From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 1/2] packet: do skb_probe_transport_header when we
 actually have data
Date: Sat, 07 Nov 2015 04:42:56 -0800
Message-ID: <1446900176.17135.4.camel@edumazet-glaptop2.roam.corp.google.com>
References: <cover.1446842228.git.daniel@iogearbox.net>
	 <5cdcd969eec9228a18c0dc54f9cc4b7b6b07ce05.1446842228.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, davem@davemloft.net, willemb@google.com,
	tklauser@distanz.ch, netdev@vger.kernel.org,
	Jason Wang <jasowang@redhat.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34177 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752085AbbKGMnA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Nov 2015 07:43:00 -0500
Received: by padhx2 with SMTP id hx2so142128980pad.1
        for <netdev@vger.kernel.org>; Sat, 07 Nov 2015 04:42:59 -0800 (PST)
In-Reply-To: <5cdcd969eec9228a18c0dc54f9cc4b7b6b07ce05.1446842228.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 2015-11-06 at 22:02 +0100, Daniel Borkmann wrote:
> In tpacket_fill_skb() commit c1aad275b029 ("packet: set transport
> header before doing xmit") and later on 40893fd0fd4e ("net: switch
> to use skb_probe_transport_header()") was probing for a transport
> header on the skb from a ring buffer slot, but at a time, where
> the skb has _not even_ been filled with data yet. So that call into
> the flow dissector is pretty useless. Lets do it after we've set
> up the skb frags.
> 
> Fixes: c1aad275b029 ("packet: set transport header before doing xmit")
> Reported-by: Eric Dumazet <edumazet@google.com>
> Cc: Jason Wang <jasowang@redhat.com>


> +	if (!packet_use_direct_xmit(po))
> +		skb_probe_transport_header(skb, 0);
> +

Thanks Daniel for working on this.

The if (!packet_use_direct_xmit(po)) test looks dubious.

Setting transport header has nothing to do with bypassing qdisc ?

This might lead to hard to debug problems, for drivers expecting
transport header being set ?

Maybe this needs a special socket flag, but this does not seem worth the pain.

(This would be different of course if trafgen was not defaulting to qdisc bypass)

Thanks.
