From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [patch] clean up tcp_sk(), 2.6.0
Date: Wed, 31 Dec 2003 01:50:13 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031231.015013.00858070.yoshfuji@linux-ipv6.org>
References: <20031230163230.GA12553@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: mingo@elte.hu
In-Reply-To: <20031230163230.GA12553@elte.hu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20031230163230.GA12553@elte.hu> (at Tue, 30 Dec 2003 17:32:30 +0100), Ingo Molnar <mingo@elte.hu> says:

> incorrect, compiles just fine on 2.6.0. The patch below is equivalent to
> the define but is also type-safe. Compiles cleanly & boots fine on
> 2.6.0.
:

> -#define tcp_sk(__sk) (&((struct tcp_sock *)__sk)->tcp)
> +static inline struct tcp_opt * tcp_sk(const struct sock *__sk)
> +{
> +	return &((struct tcp_sock *)__sk)->tcp;
> +}
>  

You probably want to convert other similar things such as 
inet_sk(), inet6_sk() etc. :-)

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
