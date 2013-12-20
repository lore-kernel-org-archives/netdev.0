From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tg3: Expand 4g_overflow_test workaround to skb
 fragments of any size.
Date: Thu, 19 Dec 2013 16:38:53 -0800
Message-ID: <1387499933.19078.379.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1387499052-7838-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	stable@vger.kernel.org, Michael Chan <mchan@broadcom.com>
To: Nithin Nayak Sujir <nsujir@broadcom.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1387499052-7838-1-git-send-email-nsujir@broadcom.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-12-19 at 16:24 -0800, Nithin Nayak Sujir wrote:
> The current driver assumes that an skb fragment can only be upto jumbo
> size. Presumably this was a fast-path optimization. This assumption is
> no longer true as fragments can be upto 32k.
> 
> Cc: stable@vger.kernel.org
> Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> ---
>  drivers/net/ethernet/broadcom/tg3.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> index f3dd93b..8ab21d7 100644
> --- a/drivers/net/ethernet/broadcom/tg3.c
> +++ b/drivers/net/ethernet/broadcom/tg3.c
> @@ -7622,7 +7622,7 @@ static inline int tg3_4g_overflow_test(dma_addr_t mapping, int len)
>  {
>  	u32 base = (u32) mapping & 0xffffffff;
>  
> -	return (base > 0xffffdcc0) && (base + len + 8 < base);
> +	return (base + len + 8 < base);
>  }

And it is actually faster ;)

What is 8 value exactly ?
