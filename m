From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net-gre-gro: Add GRE support to the GRO stack
Date: Fri, 03 Jan 2014 20:00:10 -0800
Message-ID: <1388808010.12212.152.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1388756813-10875-1-git-send-email-hkchu@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, herbert@gondor.apana.org.au,
	ogerlitz@mellanox.com, davem@davemloft.net, netdev@vger.kernel.org
To: "H.K. Jerry Chu" <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:48269 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753967AbaADEAO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 23:00:14 -0500
Received: by mail-pd0-f173.google.com with SMTP id p10so16014838pdj.4
        for <netdev@vger.kernel.org>; Fri, 03 Jan 2014 20:00:14 -0800 (PST)
In-Reply-To: <1388756813-10875-1-git-send-email-hkchu@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-01-03 at 05:46 -0800, H.K. Jerry Chu wrote:

> +struct packet_offload *gro_find_receive_by_type(__be16 type)
> +{
> +	struct list_head *offload_head = &offload_base;
> +	struct packet_offload *ptype;

missing newline

> +	list_for_each_entry_rcu(ptype, offload_head, list) {
> +		if (ptype->type != type || !ptype->callbacks.gro_receive)
> +			continue;
> +		return ptype;
> +	}
> +	return NULL;
> +}
> +EXPORT_SYMBOL(gro_find_receive_by_type);
> +
> +struct packet_offload *gro_find_complete_by_type(__be16 type)
> +{
> +	struct list_head *offload_head = &offload_base;
> +	struct packet_offload *ptype;

missing newline

> +	list_for_each_entry_rcu(ptype, offload_head, list) {
> +		if (ptype->type != type || !ptype->callbacks.gro_complete)
> +			continue;
> +		return ptype;
> +	}
> +	return NULL;
> +}
> +EXPORT_SYMBOL(gro_find_complete_by_type);
>  

I do not think there is any reason to export these two helpers.

GRO is static to the kernel.
