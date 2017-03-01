From: Gao Feng <fgao@ikuai8.com>
Subject: Re: [PATCH] netfilter: nf_conntrack_sip: fix wrong memory initialisation
Date: Thu, 2 Mar 2017 06:46:42 +0800
Message-ID: <CA+6hz4oCGP9enM7=4PS+rrChfDmomQeinsbBLOEvELP=q_H=wQ@mail.gmail.com>
References: <20170301143327.2C90B6BD30@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        Netfilter Developer Mailing List
        <netfilter-devel@vger.kernel.org>, coreteam@netfilter.org,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        stable <stable@vger.kernel.org>
To: Christophe Leroy <christophe.leroy@c-s.fr>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20170301143327.2C90B6BD30@localhost.localdomain>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 1, 2017 at 10:33 PM, Christophe Leroy
<christophe.leroy@c-s.fr> wrote:
> In commit 82de0be6862cd ("netfilter: Add helper array
> register/unregister functions"),
> struct nf_conntrack_helper sip[MAX_PORTS][4] was changed to
> sip[MAX_PORTS * 4], so the memory init should have been changed to
> memset(&sip[4 * i], 0, 4 * sizeof(sip[i]));

Yes, the memset initialization should be changed too.

Thanks
Feng

>
> But as the sip[] table is allocated in the BSS, it is already set to 0
>
> Fixes: 82de0be6862cd ("netfilter: Add helper array
> register/unregister functions")
> Cc: stable@vger.kernel.org
>
> Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
> ---
>  net/netfilter/nf_conntrack_sip.c | 2 --
>  1 file changed, 2 deletions(-)
>
> diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
> index 24174c520239..0d17894798b5 100644
> --- a/net/netfilter/nf_conntrack_sip.c
> +++ b/net/netfilter/nf_conntrack_sip.c
> @@ -1628,8 +1628,6 @@ static int __init nf_conntrack_sip_init(void)
>                 ports[ports_c++] = SIP_PORT;
>
>         for (i = 0; i < ports_c; i++) {
> -               memset(&sip[i], 0, sizeof(sip[i]));
> -
>                 nf_ct_helper_init(&sip[4 * i], AF_INET, IPPROTO_UDP, "sip",
>                                   SIP_PORT, ports[i], i, sip_exp_policy,
>                                   SIP_EXPECT_MAX,
> --
> 2.12.0
>
