From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH] net: ipv6: Fix incompatible pointer type warning
Date: Tue, 4 Jun 2013 18:34:42 +0900
Message-ID: <CAKD1Yr06MX0KOsiYVLnum0HhGN-g826qsTwnD3svu2p5Cxum5g@mail.gmail.com>
References: <1370262068-16658-1-git-send-email-emilgoode@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	kaber@trash.net, "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Emil Goode <emilgoode@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1370262068-16658-1-git-send-email-emilgoode@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 3, 2013 at 9:21 PM, Emil Goode <emilgoode@gmail.com> wrote:
> This fixes the sparse warning below about assignment from
> incompatible pointer type.
>
> In the following commit the third argument in function ipv6_chk_addr
> was changed to const and struct nf_ipv6_ops was introduced with
> the third argument of .chk_addr beeing const.
>
> 2a7851bffb008ff4882eee673da74718997b4265
> ("netfilter: add nf_ipv6_ops hook to fix xt_addrtype with IPv6")
>
> The below commit introduced the warning as the third argument of
> dummy_ipv6_chk_addr and .ipv6_chk_addr in struct pingv6_ops is
> missing a const.
>
> 6d0bfe22611602f36617bc7aa2ffa1bbb2f54c67
> ("net: ipv6: Add IPv6 support to the ping socket.")
>
> Sparse output:
>
> net/ipv6/ping.c: In function =91pingv6_init=92:
> net/ipv6/ping.c:87:27: warning:
>         assignment from incompatible pointer type [enabled by default=
]
>
> Signed-off-by: Emil Goode <emilgoode@gmail.com>
> ---
>  include/net/ping.h |    2 +-
>  net/ipv6/ping.c    |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/include/net/ping.h b/include/net/ping.h
> index 9242fa0..2db4860 100644
> --- a/include/net/ping.h
> +++ b/include/net/ping.h
> @@ -38,7 +38,7 @@ struct pingv6_ops {
>         void (*ipv6_icmp_error)(struct sock *sk, struct sk_buff *skb,=
 int err,
>                                 __be16 port, u32 info, u8 *payload);
>         int (*ipv6_chk_addr)(struct net *net, const struct in6_addr *=
addr,
> -                            struct net_device *dev, int strict);
> +                            const struct net_device *dev, int strict=
);
>  };
>
>  struct ping_table {
> diff --git a/net/ipv6/ping.c b/net/ipv6/ping.c
> index a6462d6..c2e9669 100644
> --- a/net/ipv6/ping.c
> +++ b/net/ipv6/ping.c
> @@ -73,7 +73,7 @@ int dummy_icmpv6_err_convert(u8 type, u8 code, int =
*err)
>  void dummy_ipv6_icmp_error(struct sock *sk, struct sk_buff *skb, int=
 err,
>                             __be16 port, u32 info, u8 *payload) {}
>  int dummy_ipv6_chk_addr(struct net *net, const struct in6_addr *addr=
,
> -                       struct net_device *dev, int strict)
> +                       const struct net_device *dev, int strict)
>  {
>         return 0;
>  }
> --
> 1.7.10.4
>

Acked-by: Lorenzo Colitti <lorenzo@google.com>
