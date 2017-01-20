From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH][V2] net: sctp: fix array overrun read on sctp_timer_tbl
Date: Fri, 20 Jan 2017 11:58:45 -0200
Message-ID: <20170120135845.GT3781@localhost.localdomain>
References: <20170120134542.21104-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        "David S . Miller" <davem@davemloft.net>,
        linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170120134542.21104-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 20, 2017 at 01:45:42PM +0000, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> Table sctp_timer_tbl is missing a TIMEOUT_RECONF string so
> add this in. Also compare timeout with the size of the array
> sctp_timer_tbl rather than SCTP_EVENT_TIMEOUT_MAX.  Also add
> a build time check that SCTP_EVENT_TIMEOUT_MAX is correct
> so we don't ever get this kind of mismatch between the table
> and SCTP_EVENT_TIMEOUT_MAX in the future.
> 
> Kudos to Marcel Ricardo Leitner for spotting the missing string
> and suggesting the build time sanity check.
> 
> Fixes CoverityScan CID#1397639 ("Out-of-bounds read")
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Not sure I can add the Fixes tag for you here, but:
Fixes: 7b9438de0cd4 ("sctp: add stream reconf timer")
Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Thanks

> ---
>  net/sctp/debug.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sctp/debug.c b/net/sctp/debug.c
> index 95d7b15..2e47eb2 100644
> --- a/net/sctp/debug.c
> +++ b/net/sctp/debug.c
> @@ -159,6 +159,7 @@ static const char *const sctp_timer_tbl[] = {
>  	"TIMEOUT_T4_RTO",
>  	"TIMEOUT_T5_SHUTDOWN_GUARD",
>  	"TIMEOUT_HEARTBEAT",
> +	"TIMEOUT_RECONF",
>  	"TIMEOUT_SACK",
>  	"TIMEOUT_AUTOCLOSE",
>  };
> @@ -166,7 +167,9 @@ static const char *const sctp_timer_tbl[] = {
>  /* Lookup timer debug name. */
>  const char *sctp_tname(const sctp_subtype_t id)
>  {
> -	if (id.timeout <= SCTP_EVENT_TIMEOUT_MAX)
> +	BUILD_BUG_ON(SCTP_EVENT_TIMEOUT_MAX + 1 != ARRAY_SIZE(sctp_timer_tbl));
> +
> +	if (id.timeout < ARRAY_SIZE(sctp_timer_tbl))
>  		return sctp_timer_tbl[id.timeout];
>  	return "unknown_timer";
>  }
> -- 
> 2.10.2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
