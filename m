From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH v2 net] tcp: md5: do not use alloc_percpu()
Date: Thu, 23 Oct 2014 14:44:11 -0600
Message-ID: <5449689B.9040806@gmail.com>
References: <5447FDB2.2010906@gmail.com> <544886C4.4020702@gmail.com>	 <1414041833.2094.28.camel@edumazet-glaptop2.roam.corp.google.com>	 <1414042688.2094.30.camel@edumazet-glaptop2.roam.corp.google.com>	 <5448A72D.1050806@cumulusnetworks.com>	 <1414070490.2094.39.camel@edumazet-glaptop2.roam.corp.google.com>	 <1414075405.20845.6.camel@edumazet-glaptop2.roam.corp.google.com>	 <1414081998.20845.18.camel@edumazet-glaptop2.roam.corp.google.com> <1414094338.20845.30.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Crestez Dan Leonard <cdleonard@gmail.com>, netdev@vger.kernel.org,
	Jonathan Toppins <jtoppins@cumulusnetworks.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:39758 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753641AbaJWUoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 16:44:19 -0400
Received: by mail-pa0-f49.google.com with SMTP id hz1so1755409pad.8
        for <netdev@vger.kernel.org>; Thu, 23 Oct 2014 13:44:19 -0700 (PDT)
In-Reply-To: <1414094338.20845.30.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/23/14, 1:58 PM, Eric Dumazet wrote:
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 1bec4e76d88c..39ec0c379545 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -2868,61 +2868,42 @@ EXPORT_SYMBOL(compat_tcp_getsockopt);
>   #endif
>
>   #ifdef CONFIG_TCP_MD5SIG
> -static struct tcp_md5sig_pool __percpu *tcp_md5sig_pool __read_mostly;
> +static DEFINE_PER_CPU(struct tcp_md5sig_pool, tcp_md5sig_pool);
>   static DEFINE_MUTEX(tcp_md5sig_mutex);
> -
> -static void __tcp_free_md5sig_pool(struct tcp_md5sig_pool __percpu *pool)
> -{
> -	int cpu;
> -
> -	for_each_possible_cpu(cpu) {
> -		struct tcp_md5sig_pool *p = per_cpu_ptr(pool, cpu);
> -
> -		if (p->md5_desc.tfm)
> -			crypto_free_hash(p->md5_desc.tfm);
> -	}
> -	free_percpu(pool);
> -}
> +static bool tcp_md5sig_pool_populated = false;

global variables do not need to be initialized to 0.

I'll see how this applies to v3.4 and build an image.

Thanks,
David
