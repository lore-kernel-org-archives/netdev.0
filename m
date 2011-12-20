From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [Devel] [PATCH] SUNRPC: search for service transports in network
 namespace context
Date: Tue, 20 Dec 2011 14:25:53 +0400
Message-ID: <4EF062B1.3030401@parallels.com>
References: <20111220101419.5673.21926.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>, <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, <neilb-l3A5Bk7waGM@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
To: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20111220101419.5673.21926.stgit-bi+AKbBUZKagILUCTcTcHdKyNwTtLsGr@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 12/20/2011 03:14 PM, Stanislav Kinsbursky wrote:
> Service transports are parametrized by network namespace. And thus lookup of
> transport instance have to take network namespace into account.
>
> Signed-off-by: Stanislav Kinsbursky<skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
>
> ---
>   fs/lockd/svc.c                  |    2 +-
>   fs/nfsd/nfsctl.c                |    4 ++--
>   include/linux/sunrpc/svc_xprt.h |    3 ++-
>   net/sunrpc/svc_xprt.c           |    6 +++++-
>   4 files changed, 10 insertions(+), 5 deletions(-)
>
> diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
> index c061b9a..ff379ff 100644
> --- a/fs/lockd/svc.c
> +++ b/fs/lockd/svc.c
> @@ -193,7 +193,7 @@ static int create_lockd_listener(struct svc_serv *serv, const char *name,
>   {
>   	struct svc_xprt *xprt;
>
> -	xprt = svc_find_xprt(serv, name, family, 0);
> +	xprt = svc_find_xprt(serv, name,&init_net, family, 0);
>   	if (xprt == NULL)
>   		return svc_create_xprt(serv, name,&init_net, family, port,
>   						SVC_SOCK_DEFAULTS);

I might be missing something, but isn't it (at least part of it) already 
merged in commit fc5d00b04a3a58cac8620403dfe9f43f72578ec1 ?

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
