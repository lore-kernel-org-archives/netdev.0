From: Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
Subject: Re: [PATCH] Fix for possible null pointer dereference in auth.c
Date: Thu, 15 May 2014 18:07:01 -0400
Message-ID: <CAABAsM69JO2F95+uVzbSzOSbnNz2ae0kdffy8m-pGDRr_QR=+g@mail.gmail.com>
References: <1400190998-28153-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Rickard Strandqvist <rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1400190998-28153-1-git-send-email-rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, May 15, 2014 at 5:56 PM, Rickard Strandqvist
<rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org> wrote:
> There is otherwise a risk of a possible null pointer dereference.
>
> Was largely found by using a static code analysis program called cppc=
heck.
>
> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigit=
al.se>
> ---
>  net/sunrpc/auth.c |   10 +++++++---
>  1 fil =C3=A4ndrad, 7 till=C3=A4gg(+), 3 borttagningar(-)
>
> diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
> index 5285ead..3a55698 100644
> --- a/net/sunrpc/auth.c
> +++ b/net/sunrpc/auth.c
> @@ -801,10 +801,14 @@ rpcauth_invalcred(struct rpc_task *task)
>  {
>         struct rpc_cred *cred =3D task->tk_rqstp->rq_cred;
>
> -       dprintk("RPC: %5u invalidating %s cred %p\n",
> -               task->tk_pid, cred->cr_auth->au_ops->au_name, cred);
> -       if (cred)
> +       if (cred) {
> +               dprintk("RPC: %5u invalidating %s cred %p\n",
> +                       task->tk_pid, cred->cr_auth->au_ops->au_name,=
 cred);
> +
>                 clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
> +       }
> +       else
> +               dprintk("RPC: %5u invalidating is NULL\n", task->tk_p=
id);
>  }
>
>

Can you please explain how we can get to rpcauth_invalcred() without a
valid cred pointer? I'm not seeing it...

Cheers
  Trond
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
