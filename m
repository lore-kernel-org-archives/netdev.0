From: Feng Gao <gfree.wind@gmail.com>
Subject: Re: [PATCH nf-next] netfilter: log: Check param to avoid overflow in nf_log_set
Date: Mon, 29 Aug 2016 06:36:14 +0800
Message-ID: <CA+6hz4o+ma5A0oshA4ufRKXOd21yxES9PDWPJ291YRsEF3iHEg@mail.gmail.com>
References: <1472394618-5711-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        Patrick McHardy <kaber@trash.net>,
        "David S. Miller" <davem@davemloft.net>,
        Netfilter Developer Mailing List
        <netfilter-devel@vger.kernel.org>, coreteam@netfilter.org,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Gao Feng <fgao@ikuai8.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1472394618-5711-1-git-send-email-fgao@ikuai8.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 28, 2016 at 10:30 PM,  <fgao@ikuai8.com> wrote:
> From: Gao Feng <fgao@ikuai8.com>
>
> The nf_log_set is an interface function, so it should do the strict sanity
> check of parameters. Add  one sanity check for pf, it could not exceed
> NFPROTO_NUMPROTO, and print error log when pf is invalid.
>
> Signed-off-by: Gao Feng <fgao@ikuai8.com>
> ---
>  net/netfilter/nf_log.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
> index aa5847a..02ce0b9 100644
> --- a/net/netfilter/nf_log.c
> +++ b/net/netfilter/nf_log.c
> @@ -43,8 +43,10 @@ void nf_log_set(struct net *net, u_int8_t pf, const struct nf_logger *logger)
>  {
>         const struct nf_logger *log;
>
> -       if (pf == NFPROTO_UNSPEC)
> +       if (pf == NFPROTO_UNSPEC || pf >= NFPROTO_NUMPROTO) {
> +               pr_err("Wrong pf(%d) for nf log", pf);
>                 return;
> +       }
>
>         mutex_lock(&nf_log_mutex);
>         log = nft_log_dereference(net->nf.nf_loggers[pf]);
> --
> 1.9.1
>
>

BTW, another similar interface function "nf_log_register" checks
sanity of param "pf".
So I think nf_log_set also need to check if param "pf" exceeds the valid range.
