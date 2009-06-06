From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next 2/3] net: Fix memcpy_toiovecend() to use the
	right offset
Date: Sun, 7 Jun 2009 00:13:21 +0300
Message-ID: <20090606211321.GC28614@redhat.com>
References: <1244230544.1526.77.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:33526 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751881AbZFFVON (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Jun 2009 17:14:13 -0400
Content-Disposition: inline
In-Reply-To: <1244230544.1526.77.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 05, 2009 at 12:35:44PM -0700, Sridhar Samudrala wrote:
> Increment the iovec base by the offset passed in for the initial
> copy_to_user() in memcpy_to_iovecend().
> 
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> diff --git a/net/core/iovec.c b/net/core/iovec.c
> index 40a76ce..16ad45d 100644
> --- a/net/core/iovec.c
> +++ b/net/core/iovec.c
> @@ -112,9 +112,9 @@ int memcpy_toiovecend(const struct iovec *iov, unsigned char *kdata,
>  			continue;
>  		}
>  		copy = min_t(unsigned int, iov->iov_len - offset, len);
> -		offset = 0;
> -		if (copy_to_user(iov->iov_base, kdata, copy))
> +		if (copy_to_user(iov->iov_base + offset, kdata, copy))
>  			return -EFAULT;
> +		offset = 0;
>  		kdata += copy;
>  		len -= copy;
>  	}
> 
> 
> 

-- 
MST
