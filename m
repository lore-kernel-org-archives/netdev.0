From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] filter: do not output bpf image address for
 security reason
Date: Sat, 18 May 2013 02:11:18 +0100
Message-ID: <1368839478.3469.70.camel@deadeye.wl.decadent.org.uk>
References: <1368833499.3301.126.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Daniel Borkmann <dborkman@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:7243 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751449Ab3ERBLX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 21:11:23 -0400
In-Reply-To: <1368833499.3301.126.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-05-17 at 16:31 -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Do not leak starting address of BPF JIT code, as it might help
> intruders to perform an attack.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Daniel Borkmann <dborkman@redhat.com>
> ---
>  include/linux/filter.h |    7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/filter.h b/include/linux/filter.h
> index c050dcc..08cda1c 100644
> --- a/include/linux/filter.h
> +++ b/include/linux/filter.h
> @@ -58,10 +58,11 @@ extern void bpf_jit_free(struct sk_filter *fp);
>  static inline void bpf_jit_dump(unsigned int flen, unsigned int proglen,
>  				u32 pass, void *image)
>  {
> -	pr_err("flen=%u proglen=%u pass=%u image=%p\n",
> -	       flen, proglen, pass, image);
> +	/* Do not output address (image) for security reason */
> +	pr_err("flen=%u proglen=%u pass=%u image=10\n",

Not "%pK"?

Ben.

> +	       flen, proglen, pass);
>  	if (image)
> -		print_hex_dump(KERN_ERR, "JIT code: ", DUMP_PREFIX_ADDRESS,
> +		print_hex_dump(KERN_ERR, "JIT code: ", DUMP_PREFIX_OFFSET,
>  			       16, 1, image, proglen, false);
>  }
>  #define SK_RUN_FILTER(FILTER, SKB) (*FILTER->bpf_func)(SKB, FILTER->insns)


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
