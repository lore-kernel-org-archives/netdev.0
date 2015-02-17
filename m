From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: Re: [PATCH] ipv4: ip_check_defrag should correctly check return value
 of skb_copy_bits
Date: Tue, 17 Feb 2015 17:33:47 +0400
Message-ID: <CAOJe8K0dtLufmLmRU2az=ZX8Wu1JsBS-U=jewRGCQkL8atXr1Q@mail.gmail.com>
References: <1424169226-30112-1-git-send-email-al.drozdov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexander Drozdov <al.drozdov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424169226-30112-1-git-send-email-al.drozdov@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/17/15, Alexander Drozdov <al.drozdov@gmail.com> wrote:
> skb_copy_bits() returns zero on success and negative value on error,
> so it is needed to invert the condition in ip_check_defrag().
>

Nice. Grepping through the net directory shows that the  skb_copy_bits()
return value is completely ignored in net/wireless/util.c


> Fixes: 1bf3751ec90c ("ipv4: ip_check_defrag must not modify skb before
> unsharing")
> Signed-off-by: Alexander Drozdov <al.drozdov@gmail.com>
> ---
>  net/ipv4/ip_fragment.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
> index e5b6d0d..2c8d98e 100644
> --- a/net/ipv4/ip_fragment.c
> +++ b/net/ipv4/ip_fragment.c
> @@ -664,7 +664,7 @@ struct sk_buff *ip_check_defrag(struct sk_buff *skb, u32
> user)
>  	if (skb->protocol != htons(ETH_P_IP))
>  		return skb;
>
> -	if (!skb_copy_bits(skb, 0, &iph, sizeof(iph)))
> +	if (skb_copy_bits(skb, 0, &iph, sizeof(iph)) < 0)
>  		return skb;
>
>  	if (iph.ihl < 5 || iph.version != 4)
> --
> 1.9.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
