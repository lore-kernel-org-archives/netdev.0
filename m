From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH v4 3/9] net: xfrm: use __this_cpu_read per-cpu helper
Date: Tue, 13 Nov 2012 08:21:01 +0100
Message-ID: <20121113072101.GG22290@secunet.com>
References: <50A1A7C9.3060703@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Kernel-Maillist <linux-kernel@vger.kernel.org>,
	cl@linux-foundation.org
To: Shan Wei <shanwei88@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:44090 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751646Ab2KMHVI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2012 02:21:08 -0500
Content-Disposition: inline
In-Reply-To: <50A1A7C9.3060703@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 13, 2012 at 09:52:09AM +0800, Shan Wei wrote:
> From: Shan Wei <davidshan@tencent.com>
> 

Please add a proper commit message, explaining why you do this change.

> 
> Signed-off-by: Shan Wei <davidshan@tencent.com>
> ---
> v4:
>   derefrence pointer before reading to avoid compile warning.
> ---
>  net/xfrm/xfrm_ipcomp.c |    8 +++-----
>  1 files changed, 3 insertions(+), 5 deletions(-)
> 
> diff --git a/net/xfrm/xfrm_ipcomp.c b/net/xfrm/xfrm_ipcomp.c
> index e5246fb..2906d52 100644
> --- a/net/xfrm/xfrm_ipcomp.c
> +++ b/net/xfrm/xfrm_ipcomp.c
> @@ -276,18 +276,16 @@ static struct crypto_comp * __percpu *ipcomp_alloc_tfms(const char *alg_name)
>  	struct crypto_comp * __percpu *tfms;
>  	int cpu;
>  
> -	/* This can be any valid CPU ID so we don't need locking. */
> -	cpu = raw_smp_processor_id();
>  
>  	list_for_each_entry(pos, &ipcomp_tfms_list, list) {
>  		struct crypto_comp *tfm;
>  
> -		tfms = pos->tfms;
> -		tfm = *per_cpu_ptr(tfms, cpu);
> +		/* This can be any valid CPU ID so we don't need locking. */
> +		tfm = __this_cpu_read(*pos->tfms);

This should just fetch the tfm pointer, so why exactly __this_cpu_read
is better than __this_cpu_ptr? Please keep in mind that performance is
not the most important thing here. It's much more important that it
works in any case.
