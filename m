From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net] net: pktgen: fix pkt_size
Date: Thu, 29 Sep 2016 20:11:11 +0300
Message-ID: <407513f4-1140-a5a0-9eb3-ed09abec4273@cogentembedded.com>
References: <c518daf73fb1c6d0835ee9ff05ce6b4d20972145.1475154278.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Bogdan Hamciuc <bogdan.hamciuc@freescale.com>,
        Ben Greear <greearb@candelatech.com>
To: Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f52.google.com ([209.85.215.52]:36734 "EHLO
        mail-lf0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755619AbcI2RLP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 13:11:15 -0400
Received: by mail-lf0-f52.google.com with SMTP id g62so86188893lfe.3
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 10:11:14 -0700 (PDT)
In-Reply-To: <c518daf73fb1c6d0835ee9ff05ce6b4d20972145.1475154278.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 09/29/2016 05:04 PM, Paolo Abeni wrote:

> The commit 879c7220e828 ("net: pktgen: Observe needed_headroom
> of the device") increased the 'pkt_overhead' field value by
> LL_RESERVED_SPACE.
> As a side effect the generated packet size, computed as:
>
> 	/* Eth + IPh + UDPh + mpls */
> 	datalen = pkt_dev->cur_pkt_size - 14 - 20 - 8 -
> 		  pkt_dev->pkt_overhead;
>
> is decreased by the same value.
> The above changed slightly the behavior of existing pktgen users,
> and made the interface somewhat inconsistent.
> Fix it by restoring the previous pkt_overhead value and using
> LL_RESERVED_SPACE as extralen in skb allocation.
> Also, change pktgen_alloc_skb() to only partially reserve
> the headroom to allow the caller to prefetch from ll header
> start.
>
> Fixes: 879c7220e828 ("net: pktgen: Observe needed_headroom of the device")
> Suggested-by: Ben Greear <greearb@candelatech.com>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> ---
>  net/core/pktgen.c | 21 ++++++++++-----------
>  1 file changed, 10 insertions(+), 11 deletions(-)
>
> diff --git a/net/core/pktgen.c b/net/core/pktgen.c
> index bbd118b..5c9b397 100644
> --- a/net/core/pktgen.c
> +++ b/net/core/pktgen.c
[...]
> @@ -2796,8 +2796,9 @@ static struct sk_buff *pktgen_alloc_skb(struct net_device *dev,
>  		 skb = __netdev_alloc_skb(dev, size, GFP_NOWAIT);
>  	}
>
> +	/* the caller prefetch from skb->data and reserve for the mac hdr */

    Pre-fetches and reserves?

[...]

MBR, Sergei
