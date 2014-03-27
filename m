From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net] net: Account for all vlan headers in
 skb_mac_gso_segment
Date: Thu, 27 Mar 2014 15:21:30 -0700
Message-ID: <1395958890.12610.324.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1395955578-16715-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:40781 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757009AbaC0WVc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 18:21:32 -0400
Received: by mail-pb0-f49.google.com with SMTP id jt11so4072738pbb.22
        for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 15:21:32 -0700 (PDT)
In-Reply-To: <1395955578-16715-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-03-27 at 17:26 -0400, Vlad Yasevich wrote:

> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 869c7af..cac38ba 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -2866,8 +2866,9 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
>  	int err = -ENOMEM;
>  	int i = 0;
>  	int pos;
> +	int dummy;
>  
> -	proto = skb_network_protocol(head_skb);
> +	proto = skb_network_protocol(head_skb, &dummy);
>  	if (unlikely(!proto))
>  		return ERR_PTR(-EINVAL);
>  

I am wondering if '&dummy' could be replaced by &doffset.

We have :

unsigned int doffset = head_skb->data - skb_mac_header(head_skb);

It looks like this is the same content than 'dummy', right ?
