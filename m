From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] skbuff: Extend gso_type to unsigned int.
Date: Wed, 05 Apr 2017 06:34:26 -0700 (PDT)
Message-ID: <20170405.063426.330966962521980983.davem@davemloft.net>
References: <1491207352-27585-1-git-send-email-steffen.klassert@secunet.com>
        <1491207352-27585-2-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41934 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755120AbdDENea (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 09:34:30 -0400
In-Reply-To: <1491207352-27585-2-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Mon, 3 Apr 2017 10:15:52 +0200

> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 9f78109..8796b93 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -257,7 +257,7 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
>  
>  	/* make sure we initialize shinfo sequentially */
>  	shinfo = skb_shinfo(skb);
> -	memset(shinfo, 0, offsetof(struct skb_shared_info, dataref));
> +	memset(shinfo, 0, offsetof(struct skb_shared_info, _unused));
>  	atomic_set(&shinfo->dataref, 1);
>  	kmemcheck_annotate_variable(shinfo->destructor_arg);
>  

There is another memset() that needs this conversion in __build_skb().
