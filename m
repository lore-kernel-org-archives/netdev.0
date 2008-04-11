From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][NET_SCHED] cls_u32: refcounting fix for u32_delete()
Date: Fri, 11 Apr 2008 14:55:27 +0200
Message-ID: <47FF5FBF.6030802@trash.net>
References: <20080411124519.GA2701@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Jamal Hadi Salim <hadi@cyberus.ca>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53734 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758456AbYDKMza (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 08:55:30 -0400
In-Reply-To: <20080411124519.GA2701@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> [NET_SCHED] cls_u32: refcounting fix for u32_delete()
> 
> @@ -441,8 +443,10 @@ static int u32_delete(struct tcf_proto *tp, unsigned long arg)
>  	if (tp->root == ht)
>  		return -EINVAL;
>  
> -	if (--ht->refcnt == 0)
> +	if (ht->refcnt == 1) {
> +		ht->refcnt--;
>  		u32_destroy_hnode(tp, ht);
> +	}
>  

Shouldn't the refcount be decremented unconditionally?
Otherwise I'd suggest to reject the removal if refcnt > 1,
but silently doing nothing doesn't seem right.
