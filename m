From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next RFC] net: Generic XDP
Date: Wed, 19 Apr 2017 21:40:49 -0400 (EDT)
Message-ID: <20170419.214049.2190624657363276447.davem@davemloft.net>
References: <20170418.150708.1605529107204449972.davem@davemloft.net>
        <20170418.152916.1361453741909754079.davem@davemloft.net>
        <20170419142903.GJ4730@C02RW35GFVH8.dhcp.broadcom.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, michael.chan@broadcom.com,
        netdev@vger.kernel.org, xdp-newbies@vger.kernel.org
To: andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35796 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935454AbdDTBk4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 21:40:56 -0400
In-Reply-To: <20170419142903.GJ4730@C02RW35GFVH8.dhcp.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <andy@greyhouse.net>
Date: Wed, 19 Apr 2017 10:29:03 -0400

> So I tried a variety of things and the simplest change on top of yours that
> works well for xdp1, xdp2, and xdp_tx_iptunnel. 
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index b3d3a6e..1bab3dc 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4316,11 +4316,11 @@ static u32 netif_receive_generic_xdp(struct sk_buff *skb,
>  
>  	off = xdp.data - orig_data;
>  	if (off)
> -		__skb_push(skb, off);
> +		__skb_push(skb, -off);

We have to handle both pushing and popping headers, so could you
please test the snippet I asked you to try?

> 	if (off > 0)
> 		__skb_pull(skb, off);
> 	else if (off < 0)
> 		__skb_push(skb, -off);

Thanks.
