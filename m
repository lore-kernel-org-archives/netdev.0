From: Liping Zhang <zlpnobody@gmail.com>
Subject: Re: [patch] netfilter: nf_tables: underflow in nft_parse_u32_check()
Date: Wed, 12 Oct 2016 15:27:19 +0800
Message-ID: <CAML_gOedjw6uJqp13YkGfXoLQTd_ikOC8OoUA4oXv15RYsgoUg@mail.gmail.com>
References: <20161012060811.GE12841@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        Laura Garcia Liebana <nevola@gmail.com>,
        Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        Netfilter Developer Mailing List
        <netfilter-devel@vger.kernel.org>, coreteam@netfilter.org,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20161012060811.GE12841@mwanda>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2016-10-12 14:08 GMT+08:00 Dan Carpenter <dan.carpenter@oracle.com>:
> We don't want to allow negatives here.
>
> Fixes: 36b701fae12a ('netfilter: nf_tables: validate maximum value of u32 netlink attributes')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>
> diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
> index b70d3ea..dd55187 100644
> --- a/net/netfilter/nf_tables_api.c
> +++ b/net/netfilter/nf_tables_api.c
> @@ -4423,7 +4423,7 @@ static int nf_tables_check_loops(const struct nft_ctx *ctx,
>   */

I think it's better if you can convert it to follows:

>  unsigned int nft_parse_u32_check(const struct nlattr *attr, int max, u32 *dest)

int nft_parse_u32_check(const struct nlattr *attr, u32 max, u32 *dest)

>  {
> -       int val;
> +       uint val;

            u32 val;

>
>         val = ntohl(nla_get_be32(attr));
>         if (val > max)
