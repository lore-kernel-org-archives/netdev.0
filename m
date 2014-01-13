From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] sctp: remove a redundant NULL check
Date: Mon, 13 Jan 2014 09:02:58 -0500
Message-ID: <20140113140258.GA4614@hmsreliant.think-freely.org>
References: <20140113134608.GA5232@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140113134608.GA5232@elgon.mountain>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 13, 2014 at 04:46:08PM +0300, Dan Carpenter wrote:
> It confuses Smatch when we check "sinit" for NULL and then non-NULL and
> that causes a false positive warning later.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index d32dae78a486..27f1717170c2 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -1743,7 +1743,7 @@ static int sctp_sendmsg(struct kiocb *iocb, struct sock *sk,
>  		 * either the default or the user specified stream counts.
>  		 */
>  		if (sinfo) {
> -			if (!sinit || (sinit && !sinit->sinit_num_ostreams)) {
> +			if (!sinit || !sinit->sinit_num_ostreams) {
>  				/* Check against the defaults. */
>  				if (sinfo->sinfo_stream >=
>  				    sp->initmsg.sinit_num_ostreams) {
Acked-by: Neil Horman <nhorman@tuxdriver.com>

> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
