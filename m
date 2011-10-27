From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH v6 5/8] SUNRPC: cleanup service destruction
Date: Thu, 27 Oct 2011 17:30:38 -0400
Message-ID: <20111027213038.GD31669@fieldses.org>
References: <20111025100826.12689.46944.stgit@localhost6.localdomain6>
 <20111025101716.12689.81697.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
	xemul@parallels.com, neilb@suse.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net, devel@openvz.org
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20111025101716.12689.81697.stgit@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 25, 2011 at 02:17:18PM +0300, Stanislav Kinsbursky wrote:
> svc_unregister() call have to be removed from svc_destroy() since it will be
> called in sv_shutdown callback.

It would be clearer that you're *moving* this if this were merged with
the following patch.  And without doing that the series isn't quite
bisectable, unless I'm missing something.

--b.

> 
> Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
> 
> ---
>  net/sunrpc/svc.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index 918edc3..407462f 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -530,7 +530,6 @@ svc_destroy(struct svc_serv *serv)
>  	if (svc_serv_is_pooled(serv))
>  		svc_pool_map_put();
>  
> -	svc_unregister(serv);
>  	kfree(serv->sv_pools);
>  	kfree(serv);
>  }
> 
