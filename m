From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] ipv4: processing ancillary IP_TOS or IP_TTL
Date: Thu, 15 Aug 2013 21:35:05 -0700
Message-ID: <1376627705.4648.5.camel@edumazet-glaptop>
References: <cover.1376494030.git.ffusco@redhat.com>
	 <d54a214ad9301352128f2b3300c0eaf91cc6e12e.1376494032.git.ffusco@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Francesco Fusco <ffusco@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:53739 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750902Ab3HPEfH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Aug 2013 00:35:07 -0400
Received: by mail-pa0-f51.google.com with SMTP id lf1so1438670pab.10
        for <netdev@vger.kernel.org>; Thu, 15 Aug 2013 21:35:06 -0700 (PDT)
In-Reply-To: <d54a214ad9301352128f2b3300c0eaf91cc6e12e.1376494032.git.ffusco@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-08-14 at 17:48 +0200, Francesco Fusco wrote:

> @@ -1511,6 +1517,11 @@ void ip_send_unicast_reply(struct net *net, struct sk_buff *skb, __be32 daddr,
>  	inet = &get_cpu_var(unicast_sock);
>  
>  	inet->tos = arg->tos;
> +
> +	ipc.tos = ip_hdr(skb)->tos;

Why both inet->tos and ipc.tos must be set ?

This is very confusing, as if you were not 100% sure of your patch.


> +	ipc.ttl = inet->uc_ttl;

	ipc.ttl = -1;

> +	ipc.priority = skb->priority;
> +
>  	sk = &inet->sk;
>  	sk->sk_priority = skb->priority;

Why both sk->sk_priority and ipc.priority must be set ?

>  	sk->sk_protocol = ip_hdr(skb)->protocol;
