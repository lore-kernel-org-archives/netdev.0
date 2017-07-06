From: Ethan Zhao <ethan.kernel@gmail.com>
Subject: Re: [PATCH] sctp: set the value of flowi6_oif to sk_bound_dev_if to
 make sctp_v6_get_dst to find the correct route entry.
Date: Thu, 6 Jul 2017 17:03:54 +0800
Message-ID: <CABawtvMgVqA-zyOn7g+gSmqgTY9nG2vtEm_pan2F_huXz__Kfw@mail.gmail.com>
References: <1499324409-12489-1-git-send-email-lizheng043@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>, vyasevich@gmail.com,
        nhorman@tuxdriver.com, linux-sctp@vger.kernel.org,
        David Miller <davem@davemloft.net>, jmorris@namei.org,
        james.z.li@ericsson.com, allen.y.zhao@ericsson.com,
        feng.qiu@ericsson.com
To: Zheng Li <lizheng043@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1499324409-12489-1-git-send-email-lizheng043@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Zheng,

On Thu, Jul 6, 2017 at 3:00 PM, Zheng Li <lizheng043@gmail.com> wrote:
> From: Zheng Li <james.z.li@ericsson.com>
>
> if there are several same route entries with different outgoing net device,
> application's socket specifies the oif through setsockopt with
> SO_BINDTODEVICE, sctpv6 should choose the route entry whose outgoing net
> device is the oif which was specified by socket, set the value of
> flowi6_oif to sk->sk_bound_dev_if to make sctp_v6_get_dst to find the
> correct route entry.
>
> Signed-off-by: Zheng Li <james.z.li@ericsson.com>
> ---
>  net/sctp/ipv6.c | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
> index f5b45b8..2a186b20 100644
> --- a/net/sctp/ipv6.c
> +++ b/net/sctp/ipv6.c
> @@ -252,6 +252,8 @@ static void sctp_v6_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
>         fl6->flowi6_proto = IPPROTO_SCTP;
>         if (ipv6_addr_type(&daddr->v6.sin6_addr) & IPV6_ADDR_LINKLOCAL)
>                 fl6->flowi6_oif = daddr->v6.sin6_scope_id;
> +       else if (asoc)
> +               fl6->flowi6_oif = asoc->base.sk->sk_bound_dev_if;

  Yes, ipv4 does the same way,  but sctp ipv4 code aslo set the
source port to htons(asoc->base.bind_addr.port) meanwhile;
:>

Thanks,
Ethan

>
>         pr_debug("%s: dst=%pI6 ", __func__, &fl6->daddr);
>
> --
> 2.7.4
>
