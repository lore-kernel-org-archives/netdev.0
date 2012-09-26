From: Steffen Klassert <steffen.klassert-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 08/11] crypto: pass crypto_user module to
 netlink_dump_start
Date: Wed, 26 Sep 2012 07:49:45 +0200
Message-ID: <20120926054945.GE4221@secunet.com>
References: <1348635140-20225-1-git-send-email-gaofeng@cn.fujitsu.com>
 <1348635140-20225-8-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org,
	linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jengelh-9+2X+4sQBs8@public.gmane.org,
	stephen.hemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
To: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1348635140-20225-8-git-send-email-gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 26, 2012 at 12:52:17PM +0800, Gao feng wrote:
> use proper netlink_dump_control.done and .module to avoid panic.
> 
> Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> Cc: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
> ---
>  crypto/crypto_user.c |    6 +++++-
>  1 files changed, 5 insertions(+), 1 deletions(-)
> 
> diff --git a/crypto/crypto_user.c b/crypto/crypto_user.c
> index ba2c611..b5cb32b 100644
> --- a/crypto/crypto_user.c
> +++ b/crypto/crypto_user.c
> @@ -249,6 +249,7 @@ out_err:
>  
>  static int crypto_dump_report_done(struct netlink_callback *cb)
>  {
> +	netlink_dump_done(cb);
>  	return 0;

It's probaply better to return the return value of netlink_dump_done()
instead. Right now, netlink_dump_done() returns 0 in any case,
but this might change over time.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
