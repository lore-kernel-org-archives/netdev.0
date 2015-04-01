From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] crypto: algif - explicitly mark end of data
Date: Wed, 01 Apr 2015 15:32:02 -0400 (EDT)
Message-ID: <20150401.153202.1090532458862532893.davem@davemloft.net>
References: <20150330212543.7133.97653.stgit@tstruk-mobl1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-crypto@vger.kernel.org,
	herbert@gondor.apana.org.au
To: tadeusz.struk@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60186 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753057AbbDATcG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 15:32:06 -0400
In-Reply-To: <20150330212543.7133.97653.stgit@tstruk-mobl1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tadeusz Struk <tadeusz.struk@intel.com>
Date: Mon, 30 Mar 2015 14:25:43 -0700

> +	int mark = 0, err = -ENOMEM;
>  
>  	lock_sock(sk);
>  	req = kmalloc(reqlen, GFP_KERNEL);
 ...
> @@ -573,10 +572,11 @@ static int skcipher_recvmsg_async(struct socket *sock, struct msghdr *msg,
>  			kfree(sreq->tsg);
>  			sreq->tsg = tmp;
>  			tx_nents *= 2;
> +			mark = 1;
 ...
> @@ -604,6 +604,9 @@ static int skcipher_recvmsg_async(struct socket *sock, struct msghdr *msg,
>  		iov_iter_advance(&msg->msg_iter, used);
>  	}
>  
> +	if (mark)
> +		sg_mark_end(sreq->tsg + txbufs - 1);

Please use type 'bool' and true/false for 'mark'.
