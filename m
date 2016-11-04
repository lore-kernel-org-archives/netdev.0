From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v2 1/2] net/sock: add an explicit sk argument
 for ip_cmsg_recv_offset()
Date: Fri, 04 Nov 2016 05:36:00 -0700
Message-ID: <1478262960.7065.459.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1478254512.git.pabeni@redhat.com>
         <1b4e5292a0c15494515423245e8eeb7adf2ebcea.1478254512.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
        linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1b4e5292a0c15494515423245e8eeb7adf2ebcea.1478254512.git.pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-11-04 at 11:28 +0100, Paolo Abeni wrote:
> So that we can use it even after orphaining the skbuff.
> 
> Suggested-by: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Signed-off-by: Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> ---
> @Eric, please add your signed off by when you feel comfortable with the patch
> as you basically authored it

> -void ip_cmsg_recv_offset(struct msghdr *msg, struct sk_buff *skb,
> -			 int tlen, int offset)
> +void ip_cmsg_recv_offset(struct msghdr *msg, struct sock *sk,
> +			 struct sk_buff *skb, int tlen, int offset)
>  {
> -	struct inet_sock *inet = inet_sk(skb->sk);
> +	struct inet_sock *inet = inet_sk(sk);
>  	unsigned int flags = inet->cmsg_flags;

My final version had :

void ip_cmsg_recv_offset(struct msghdr *msg, const struct sock *sk,
                         struct sk_buff *skb, int tlen, int offset)
{
	unsigned int flags = inet_sk(sk)->cmsg_flags;


(Ie not using "struct inet_sock *inet = ...", and a const pointer for
struct sock)

Other than that minor details :

Signed-off-by: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

Thanks !


--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
