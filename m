From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 01/13] net:  Add generic packet offload
 infrastructure.
Date: Tue, 13 Nov 2012 18:24:21 -0800
Message-ID: <1352859861.4497.0.camel@edumazet-glaptop>
References: <1352856254-29667-1-git-send-email-vyasevic@redhat.com>
	 <1352856254-29667-2-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.com
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:60523 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932375Ab2KNCYY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 21:24:24 -0500
Received: by mail-da0-f46.google.com with SMTP id n41so3471324dak.19
        for <netdev@vger.kernel.org>; Tue, 13 Nov 2012 18:24:23 -0800 (PST)
In-Reply-To: <1352856254-29667-2-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-11-13 at 20:24 -0500, Vlad Yasevich wrote:
> Create a new data structure to contain the GRO/GSO callbacks and add
> a new registration mechanism.
> 
> Singed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> ---
>  include/linux/netdevice.h |   15 ++++++++
>  net/core/dev.c            |   80 +++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 95 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index f8eda02..d15af51 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1511,6 +1511,18 @@ struct packet_type {
>  	struct list_head	list;
>  };
>  
> +struct packet_offload {
> +	__be16			type;	/* This is really htons(ether_type). */
> +	struct net_device	*dev;	/* NULL is wildcarded here	     */

Shouldnt this dev pointer be removed at some point in the patch serie ?

> +	struct sk_buff		*(*gso_segment)(struct sk_buff *skb,
> +						netdev_features_t features);
> +	int			(*gso_send_check)(struct sk_buff *skb);
> +	struct sk_buff		**(*gro_receive)(struct sk_buff **head,
> +					       struct sk_buff *skb);
> +	int			(*gro_complete)(struct sk_buff *skb);
> +	struct list_head	list;
> +};
> +
>  #include <linux/notifier.h>
>  
