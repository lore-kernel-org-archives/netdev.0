From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6:ip6_xmit remove unnecessary np NULL check
Date: Tue, 29 Nov 2016 07:26:10 -0800
Message-ID: <1480433170.18162.135.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480401179-9220-1-git-send-email-manjeet.p@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, pankaj.m@samsung.com,
        ajeet.y@samsung.com, Rohit Thapliyal <r.thapliyal@samsung.com>
To: Manjeet Pawar <manjeet.p@samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480401179-9220-1-git-send-email-manjeet.p@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-11-29 at 12:02 +0530, Manjeet Pawar wrote:
> From: Rohit Thapliyal <r.thapliyal@samsung.com>
> 
> np NULL check doesn't seem required here as it shall never
> be NULL anyways in inet6_sk(sk).
> 
> Signed-off-by: Rohit Thapliyal <r.thapliyal@samsung.com>
> Signed-off-by: Manjeet Pawar <manjeet.p@samsung.com>
> Signed-off-by: David Miller <davem@davemloft.net>
> Reviewed-by: Akhilesh Kumar <akhilesh.k@samsung.com>
> 
> ---
> v2->v3: Modified as per the suggestion from David Miller
>         ip6_xmit calls are made without checking NULL np
>         pointer, so no need to explicitly check NULL np in
>         ip6_xmit.
> 
>  include/linux/ipv6.h  | 2 +-
>  net/ipv6/ip6_output.c | 3 +--
>  2 files changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
> index a064997..6c9c604 100644
> --- a/include/linux/ipv6.h
> +++ b/include/linux/ipv6.h
> @@ -299,7 +299,7 @@ struct tcp6_timewait_sock {
>  
>  static inline struct ipv6_pinfo *inet6_sk(const struct sock *__sk)
>  {
> -	return sk_fullsock(__sk) ? inet_sk(__sk)->pinet6 : NULL;
> +	return inet_sk(__sk)->pinet6;


David suggestion was about np being NULL or not in ip6_xmit()

But have you checked inet6_sk() was never called for a TCPv6 TIMEWAIT or
SYN_RECV request ?

>  }
>  
>  static inline struct raw6_sock *raw6_sk(const struct sock *sk)
> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> index 59eb4ed..f8c63ec 100644
> --- a/net/ipv6/ip6_output.c
> +++ b/net/ipv6/ip6_output.c
> @@ -213,8 +213,7 @@ int ip6_xmit(const struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
>  	/*
>  	 *	Fill in the IPv6 header
>  	 */
> -	if (np)
> -		hlimit = np->hop_limit;
> +	hlimit = np->hop_limit;
>  	if (hlimit < 0)
>  		hlimit = ip6_dst_hoplimit(dst);
>  

This part is fine.
