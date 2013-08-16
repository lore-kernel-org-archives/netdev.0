From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] ipv4: processing ancillary IP_TOS or IP_TTL
Date: Thu, 15 Aug 2013 21:26:58 -0700
Message-ID: <1376627218.4648.2.camel@edumazet-glaptop>
References: <cover.1376494030.git.ffusco@redhat.com>
	 <d54a214ad9301352128f2b3300c0eaf91cc6e12e.1376494032.git.ffusco@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Francesco Fusco <ffusco@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:53602 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750994Ab3HPE1A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Aug 2013 00:27:00 -0400
Received: by mail-pb0-f47.google.com with SMTP id rr4so1540616pbb.6
        for <netdev@vger.kernel.org>; Thu, 15 Aug 2013 21:27:00 -0700 (PDT)
In-Reply-To: <d54a214ad9301352128f2b3300c0eaf91cc6e12e.1376494032.git.ffusco@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-08-14 at 17:48 +0200, Francesco Fusco wrote:
> If IP_TOS or IP_TTL are specified as ancillary data, then sendmsg() sends out
> packets with the specified TTL or TOS overriding the socket values specified
> with the traditional setsockopt().
> 
> If there is a per-packet specified tos, the skb->priority is set accordingly.
> The ipv4_is_multicast() function is used to fill in the right TTL value in case
> of multicast destinations.
> 
> Signed-off-by: Francesco Fusco <ffusco@redhat.com>
> ---

> @@ -1327,7 +1332,7 @@ struct sk_buff *__ip_make_skb(struct sock *sk,
>  	iph = (struct iphdr *)skb->data;
>  	iph->version = 4;
>  	iph->ihl = 5;
> -	iph->tos = inet->tos;
> +	iph->tos = (cork->tos != inet->tos) ? cork->tos : inet->tos;

Strange construct, as the following has same meaning.

	iph->tos = cork->tos;
