From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] Fix for possible null pointer dereference in auth.c
Date: Fri, 16 May 2014 16:19:39 +0400
Message-ID: <5376025B.6010202@cogentembedded.com>
References: <1400190998-28153-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <trond.myklebust@primarydata.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400190998-28153-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 16-05-2014 1:56, Rickard Strandqvist wrote:

> There is otherwise a risk of a possible null pointer dereference.

> Was largely found by using a static code analysis program called cppc=
heck.

> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigit=
al.se>
> ---
>   net/sunrpc/auth.c |   10 +++++++---
>   1 fil =C3=A4ndrad, 7 till=C3=A4gg(+), 3 borttagningar(-)

> diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
> index 5285ead..3a55698 100644
> --- a/net/sunrpc/auth.c
> +++ b/net/sunrpc/auth.c
> @@ -801,10 +801,14 @@ rpcauth_invalcred(struct rpc_task *task)
>   {
>   	struct rpc_cred *cred =3D task->tk_rqstp->rq_cred;
>
> -	dprintk("RPC: %5u invalidating %s cred %p\n",
> -		task->tk_pid, cred->cr_auth->au_ops->au_name, cred);
> -	if (cred)
> +	if (cred) {
> +		dprintk("RPC: %5u invalidating %s cred %p\n",
> +			task->tk_pid, cred->cr_auth->au_ops->au_name, cred);
> +
>   		clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
> +	}
> +	else

    } and *else* should be on the same line, and there should be {} in =
the=20
*else* arm since there's {} in the *if* arm already, according to=20
Documentation/CodingStyle.

> +		dprintk("RPC: %5u invalidating is NULL\n", task->tk_pid);

    That's not a proper English, I'm afraid.

>   }

WBR, Sergei
