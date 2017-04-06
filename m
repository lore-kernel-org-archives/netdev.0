From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] net: ipv4: netfilter: Remove unused function
 nf_nat_need_gre()
Date: Fri, 7 Apr 2017 01:06:14 +0200
Message-ID: <20170406230614.GA20513@salvia>
References: <20170401133633.GA2208@singhal-Inspiron-5558>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: simran singhal <singhalsimran0@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170401133633.GA2208@singhal-Inspiron-5558>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 01, 2017 at 07:06:33PM +0530, simran singhal wrote:
> The function nf_nat_need_gre() on being called, simply returns
> back. The function doesn't have FIXME code around.
> Hence, nf_nat_need_gre() and its calls have been removed.
> 
> Signed-off-by: simran singhal <singhalsimran0@gmail.com>
> ---
>  net/ipv4/netfilter/nf_nat_pptp.c      | 2 --
>  net/ipv4/netfilter/nf_nat_proto_gre.c | 6 ------
>  2 files changed, 8 deletions(-)
> 
> diff --git a/net/ipv4/netfilter/nf_nat_pptp.c b/net/ipv4/netfilter/nf_nat_pptp.c
> index b3ca21b..747e737 100644
> --- a/net/ipv4/netfilter/nf_nat_pptp.c
> +++ b/net/ipv4/netfilter/nf_nat_pptp.c
> @@ -282,8 +282,6 @@ pptp_inbound_pkt(struct sk_buff *skb,
>  
>  static int __init nf_nat_helper_pptp_init(void)
>  {
> -	nf_nat_need_gre();
> -
>  	BUG_ON(nf_nat_pptp_hook_outbound != NULL);
>  	RCU_INIT_POINTER(nf_nat_pptp_hook_outbound, pptp_outbound_pkt);
>  
> diff --git a/net/ipv4/netfilter/nf_nat_proto_gre.c b/net/ipv4/netfilter/nf_nat_proto_gre.c
> index edf0500..c020a4d 100644
> --- a/net/ipv4/netfilter/nf_nat_proto_gre.c
> +++ b/net/ipv4/netfilter/nf_nat_proto_gre.c
> @@ -142,9 +142,3 @@ static void __exit nf_nat_proto_gre_fini(void)
>  
>  module_init(nf_nat_proto_gre_init);
>  module_exit(nf_nat_proto_gre_fini);
> -
> -void nf_nat_need_gre(void)
> -{
> -	return;
> -}
> -EXPORT_SYMBOL_GPL(nf_nat_need_gre);

There is a good reason why we have this :)

By digging out and doing a bit of software archeology work via the
'git annotate' you know this triggers an explicit module dependency.
