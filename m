From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND 2/2] update sunrpc to use in-kernel sockets API
Date: Mon, 07 Aug 2006 20:59:10 -0700 (PDT)
Message-ID: <20060807.205910.68157131.davem@davemloft.net>
References: <1154991632.11916.6.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:6017
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932437AbWHHD70 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 23:59:26 -0400
To: sri@us.ibm.com
In-Reply-To: <1154991632.11916.6.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Mon, 07 Aug 2006 16:00:32 -0700

> Update sunrpc to use in-kernel sockets API.
> 
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
> Acked-by: James Morris <jmorris@namei.org>

Applied, thanks.

> @@ -207,7 +207,7 @@ static inline int xs_sendpages(struct so
>  		base &= ~PAGE_CACHE_MASK;
>  	}
>  
> -	sendpage = sock->ops->sendpage ? : sock_no_sendpage;
> +	sendpage = kernel_sendpage;
>  	do {
>  		int flags = XS_SENDMSG_FLAGS;
>  

Seemingly this chunk could be simplified further, by
just invoking kernel_sendpage() directly?
