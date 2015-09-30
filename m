From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH 10/12] net: sctp: avoid incorrect time_t use
Date: Wed, 30 Sep 2015 11:28:00 -0300
Message-ID: <20150930142800.GB4893@localhost.localdomain>
References: <1443612402-3000775-1-git-send-email-arnd@arndb.de>
 <1443612402-3000775-11-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, y2038@lists.linaro.org,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>, linux-sctp@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1443612402-3000775-11-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 30, 2015 at 01:26:40PM +0200, Arnd Bergmann wrote:
> We want to avoid using time_t in the kernel because of the y2038
> overflow problem. The use in sctp is not for storing seconds at
> all, but instead uses microseconds and is passed as 32-bit
> on all machines.
> 
> This patch changes the type to u32, which better fits the use.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Cc: Vlad Yasevich <vyasevich@gmail.com>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> Cc: linux-sctp@vger.kernel.org

Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

> ---
>  net/sctp/sm_make_chunk.c | 2 +-
>  net/sctp/sm_statefuns.c  | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
> index 7954c52e1794..763e06a55155 100644
> --- a/net/sctp/sm_make_chunk.c
> +++ b/net/sctp/sm_make_chunk.c
> @@ -2494,7 +2494,7 @@ static int sctp_process_param(struct sctp_association *asoc,
>  	__u16 sat;
>  	int retval = 1;
>  	sctp_scope_t scope;
> -	time_t stale;
> +	u32 stale;
>  	struct sctp_af *af;
>  	union sctp_addr_param *addr_param;
>  	struct sctp_transport *t;
> diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
> index d7eaa7354cf7..6f46aa16cb76 100644
> --- a/net/sctp/sm_statefuns.c
> +++ b/net/sctp/sm_statefuns.c
> @@ -2306,7 +2306,7 @@ static sctp_disposition_t sctp_sf_do_5_2_6_stale(struct net *net,
>  						 sctp_cmd_seq_t *commands)
>  {
>  	struct sctp_chunk *chunk = arg;
> -	time_t stale;
> +	u32 stale;
>  	sctp_cookie_preserve_param_t bht;
>  	sctp_errhdr_t *err;
>  	struct sctp_chunk *reply;
> -- 
> 2.1.0.rc2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
