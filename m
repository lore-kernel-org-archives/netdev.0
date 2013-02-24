From: "Myklebust, Trond" <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] SUNRPC: Fix possible NULL pointer dereference
Date: Sun, 24 Feb 2013 22:35:08 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9235DE4C7@SACEXCMBX04-PRD.hq.netapp.com>
References: <1361744605-28235-1-git-send-email-s.syam@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Syam Sidhardhan <syamsidhardh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1361744605-28235-1-git-send-email-s.syam-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
Content-Language: en-US
Content-ID: <81F08C3FC98A084B9A1E4358BDE18E6E-oP88Kt8RkgzdA/Lu/QRl1Q@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-02-25 at 03:53 +0530, Syam Sidhardhan wrote:
> Check for cred == NULL has to be done before accessing cred.
> 
> Signed-off-by: Syam Sidhardhan <s.syam-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
> ---
>  net/sunrpc/auth.c |    7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
> index f529404..18678a6 100644
> --- a/net/sunrpc/auth.c
> +++ b/net/sunrpc/auth.c
> @@ -695,10 +695,13 @@ rpcauth_invalcred(struct rpc_task *task)
>  {
>  	struct rpc_cred *cred = task->tk_rqstp->rq_cred;
>  
> +	if (cred == NULL)
> +		return;
> +
>  	dprintk("RPC: %5u invalidating %s cred %p\n",
>  		task->tk_pid, cred->cr_auth->au_ops->au_name, cred);
> -	if (cred)
> -		clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
> +
> +	clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
>  }
>  
>  int

Do we need that check at all?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org
www.netapp.com
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
