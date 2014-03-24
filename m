From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/4] net: Rename rxhash to hash
Date: Mon, 24 Mar 2014 15:25:24 -0700
Message-ID: <1395699924.12610.83.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.02.1403201659350.6989@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:43742 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751192AbaCXWZ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 18:25:26 -0400
Received: by mail-pa0-f42.google.com with SMTP id fb1so6109582pad.29
        for <netdev@vger.kernel.org>; Mon, 24 Mar 2014 15:25:25 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1403201659350.6989@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-03-20 at 17:09 -0700, Tom Herbert wrote:

> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 2923044..125887c 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -1277,7 +1277,7 @@ static unsigned int fanout_demux_hash(struct packet_fanout *f,
>  				      struct sk_buff *skb,
>  				      unsigned int num)
>  {
> -	return reciprocal_scale(skb->rxhash, num);
> +	return reciprocal_scale(skb_get_hash(skb), num);
>  }
>  
>  static unsigned int fanout_demux_lb(struct packet_fanout *f,

It seems that you could remove the skb_get_hash(skb) before the call to
fanout_demux_hash() then.
