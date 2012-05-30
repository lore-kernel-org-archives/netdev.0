From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 4/4] inet: use second hash in inet_csk_get_port
Date: Wed, 30 May 2012 18:42:52 +0200
Message-ID: <1338396172.2760.294.camel@edumazet-glaptop>
References: <1338363410-6562-1-git-send-email-alex.mihai.c@gmail.com>
	 <1338363410-6562-5-git-send-email-alex.mihai.c@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, gerrit@erg.abdn.ac.uk, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, Daniel Baluta <dbaluta@ixiacom.com>,
	Lucian Grijincu <lucian.grijincu@gmail.com>
To: Alexandru Copot <alex.mihai.c@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:48665 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752787Ab2E3Qm5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 12:42:57 -0400
Received: by bkcji2 with SMTP id ji2so13571bkc.19
        for <netdev@vger.kernel.org>; Wed, 30 May 2012 09:42:56 -0700 (PDT)
In-Reply-To: <1338363410-6562-5-git-send-email-alex.mihai.c@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-30 at 10:36 +0300, Alexandru Copot wrote:

> diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
> index bc06168..2f589bb 100644
> --- a/include/net/inet_hashtables.h
> +++ b/include/net/inet_hashtables.h
> @@ -81,6 +81,15 @@ struct inet_bind_bucket {
>  	struct net		*ib_net;
>  #endif
>  	unsigned short		port;
> +	union {
> +		struct in6_addr ib_addr_ipv6;
> +		struct {
> +			__be32	_1;
> +			__be32	_2;
> +			__be32	_3;
> +			__be32	ib_addr_ipv4;
> +		};
> +	};
>  	signed short		fastreuse;
>  	int			num_owners;
>  	struct hlist_node	node;

Yet another poor choice, adding two holes in this structure.
