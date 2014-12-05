From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/3] ip: Add support for IP_CHECKSUM cmsg
Date: Thu, 04 Dec 2014 17:17:49 -0800
Message-ID: <1417742269.22424.44.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1417653868-14922-1-git-send-email-therbert@google.com>
	 <1417653868-14922-4-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:35971 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932496AbaLEBRv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 20:17:51 -0500
Received: by mail-ig0-f172.google.com with SMTP id hl2so7089igb.17
        for <netdev@vger.kernel.org>; Thu, 04 Dec 2014 17:17:50 -0800 (PST)
In-Reply-To: <1417653868-14922-4-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-12-03 at 16:44 -0800, Tom Herbert wrote:

> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 221b53f..bba2e06 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -1315,8 +1315,16 @@ try_again:
>  		memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
>  		*addr_len = sizeof(*sin);
>  	}
> -	if (inet->cmsg_flags)
> +	if (inet->cmsg_flags) {
> +		/* Pull checksum past UDP header in case we are providing
> +		 * checksum in cmsg.
> +		 */
> +		if (inet->cmsg_flags & IP_CMSG_CHECKSUM)
> +			skb_postpull_rcsum(skb, skb->data,
> +					   sizeof(struct udphdr));
> +
>  		ip_cmsg_recv(msg, skb);
> +	}


Have you tried MSG_PEEK ?

You can not modify the skb, you need to do something else.
