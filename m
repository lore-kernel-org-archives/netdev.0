From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] can: use sock_efree instead of own destructor
Date: Tue, 10 Mar 2015 07:14:08 +0100
Message-ID: <54FE8BB0.9050508@hartkopp.net>
References: <1425959300-27132-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mkl@pengutronix.de,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1425959300-27132-1-git-send-email-fw@strlen.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10.03.2015 04:48, Florian Westphal wrote:
> It is identical to the can destructor.
>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Acked-by: Oliver Hartkopp <socketcan@hartkopp.net>

Hello Florian,

the other callers use it in the same way so it's a good simplification.
Btw. the name of sock_efree() is a bit misleading - nothing is free'd here.

Won't it be better to rename sock_efree(skb) with sock_put_skb(skb) or 
something like that? sock_efree() has no comment why it's named like this.

Regards,
Oliver

ps. changed from linux ML to netdev and linux-can ML in CC

> ---
>   include/linux/can/skb.h | 7 +------
>   1 file changed, 1 insertion(+), 6 deletions(-)
>
> diff --git a/include/linux/can/skb.h b/include/linux/can/skb.h
> index cc00d15..b6a52a4 100644
> --- a/include/linux/can/skb.h
> +++ b/include/linux/can/skb.h
> @@ -44,16 +44,11 @@ static inline void can_skb_reserve(struct sk_buff *skb)
>   	skb_reserve(skb, sizeof(struct can_skb_priv));
>   }
>
> -static inline void can_skb_destructor(struct sk_buff *skb)
> -{
> -	sock_put(skb->sk);
> -}
> -
>   static inline void can_skb_set_owner(struct sk_buff *skb, struct sock *sk)
>   {
>   	if (sk) {
>   		sock_hold(sk);
> -		skb->destructor = can_skb_destructor;
> +		skb->destructor = sock_efree;
>   		skb->sk = sk;
>   	}
>   }
>
