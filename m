From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [CRYPTO] api: Feed flag directly to crypto_yield
Date: Fri, 22 Sep 2006 18:16:14 -0400
Message-ID: <451460AE.2080200@garzik.org>
References: <200609222104.k8ML4JE4025619@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:16084 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S965229AbWIVWQT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2006 18:16:19 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <200609222104.k8ML4JE4025619@hera.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linux Kernel Mailing List wrote:
> diff --git a/crypto/internal.h b/crypto/internal.h
> index b110b97..7dc04ef 100644
> --- a/crypto/internal.h
> +++ b/crypto/internal.h
> @@ -67,9 +67,9 @@ static inline void crypto_kunmap(void *v
>  	kunmap_atomic(vaddr, crypto_kmap_type(out));
>  }
>  
> -static inline void crypto_yield(struct crypto_tfm *tfm)
> +static inline void crypto_yield(u32 flags)
>  {
> -	if (tfm->crt_flags & CRYPTO_TFM_REQ_MAY_SLEEP)
> +	if (flags & CRYPTO_TFM_REQ_MAY_SLEEP)
>  		cond_resched();
>  }

I would add "else cpu_relax()"

	Jeff


