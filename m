From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next] netfilter: log: Check param to avoid overflow in
 nf_log_set
Date: Mon, 29 Aug 2016 11:55:25 +0200
Message-ID: <20160829095525.GB2407@salvia>
References: <1472394618-5711-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, davem@davemloft.net,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1472394618-5711-1-git-send-email-fgao@ikuai8.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 28, 2016 at 10:30:18PM +0800, fgao@ikuai8.com wrote:
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
>  	const struct nf_logger *log;
>  
> -	if (pf == NFPROTO_UNSPEC)
> +	if (pf == NFPROTO_UNSPEC || pf >= NFPROTO_NUMPROTO) {
> +		pr_err("Wrong pf(%d) for nf log", pf);
>  		return;

I'd suggest you change this function nf_log_set() to:

        int nf_log_set(struct net *net, ...)

And update the callsites.

Then, you can simply return -EOPNOTSUPP instead and remove that
pr_err() message. This message is very unlikely to be displayed.

Thanks!
