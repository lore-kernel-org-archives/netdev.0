From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPV6: inappropriate usage of inet{,6}_sk()
Date: Tue, 28 Oct 2003 01:04:18 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031028010418.6e8960a8.davem@redhat.com>
References: <20031027.232700.97608602.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / _$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
In-Reply-To: <20031027.232700.97608602.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 27 Oct 2003 23:27:00 +0900 (JST)
YOSHIFUJI Hideaki / _$B5HF#1QL@ <yoshfuji@linux-ipv6.org> wrote:

> Hi,
> 
> I found other inappropriate usages of inet{,6}_sk() for 
> tcp_tw_bucket:
>  - inet6_sk(sk)->ipv6only
>  - inet6_sk(sk)->rcv_saddr
>  - inet_sk(sk)->rcv_saddr
> 
> Patch is against my previous patch.

Thank you for working on a fix for this.  Patch need some
small fixes before I can apply it.

> +static inline const struct in6_addr *__tcp_v6_rcv_saddr(const struct sock *sk)
> +{
> +	return likely(sk->sk_state != TCP_TIME_WAIT) ?
> +		&inet6_sk(sk)->rcv_saddr : &tcptw_sk(sk)->tw_v6_rcv_saddr;
> +}

Cannot reference inet6_sk() or tw->tw_v6_rcv_saddr outside of
CONFIG_IPV6 || CONFIG_IPV6_MODULE since these things do not exist when
those configs are both disabled.

Please verify the build of your new patch with IPV6 fully disabled.

Thank you.
