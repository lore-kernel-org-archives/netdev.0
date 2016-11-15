From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 20/39] netfilter: ipset: Use kmalloc() in comment
 extension helper
Date: Tue, 15 Nov 2016 10:48:33 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB021CCF9@AcuExch.aculab.com>
References: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
 <1479075933-4491-21-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Pablo Neira Ayuso' <pablo@netfilter.org>,
        "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.190]:52080 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752723AbcKOKsm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 05:48:42 -0500
In-Reply-To: <1479075933-4491-21-git-send-email-pablo@netfilter.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso
> Sent: 13 November 2016 22:25
> Allocate memory with kmalloc() rather than kzalloc(): the string
> is immediately initialized so it is unnecessary to zero out
> the allocated memory area.
> 
> Ported from a patch proposed by Sergey Popovich <popovich_sergei@mail.ua>.
> 
> Suggested-by: Sergey Popovich <popovich_sergei@mail.ua>
> Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
> ---
>  include/linux/netfilter/ipset/ip_set_comment.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/linux/netfilter/ipset/ip_set_comment.h
> b/include/linux/netfilter/ipset/ip_set_comment.h
> index bae5c7609be2..5444b1bbe656 100644
> --- a/include/linux/netfilter/ipset/ip_set_comment.h
> +++ b/include/linux/netfilter/ipset/ip_set_comment.h
> @@ -34,7 +34,7 @@ ip_set_init_comment(struct ip_set_comment *comment,
>  		return;
>  	if (unlikely(len > IPSET_MAX_COMMENT_SIZE))
>  		len = IPSET_MAX_COMMENT_SIZE;
> -	c = kzalloc(sizeof(*c) + len + 1, GFP_ATOMIC);
> +	c = kmalloc(sizeof(*c) + len + 1, GFP_ATOMIC);
>  	if (unlikely(!c))
>  		return;
>  	strlcpy(c->str, ext->comment, len + 1);

I think I'd do a memcpy() and zero the last byte.

Note that any other parts of 'c->' are no longer zeroed by this code fragment.

	David
