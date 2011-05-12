From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] Add libertas_disablemesh module parameter to disable
 mesh interface
Date: Wed, 11 May 2011 22:11:36 -0500
Message-ID: <1305169898.8054.19.camel@dcbw.foobar.com>
References: <1305118354-17337-1-git-send-email-silbe@activitycentral.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, devel@lists.laptop.org,
	"John W. Linville" <linville@tuxdriver.com>,
	libertas-dev@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sascha Silbe <silbe@activitycentral.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1305118354-17337-1-git-send-email-silbe@activitycentral.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-05-11 at 14:52 +0200, Sascha Silbe wrote:
> This allows individual users and deployments to disable mesh support at
> runtime, i.e. without having to build and maintain a custom kernel.

Does the mesh interface somehow cause problems, even when nothing is
using it?  I'd expect that if the mesh interface was simply left alone,
there would be no need to disable it.

Dan

> Based on a patch by Paul Fox <pgf@laptop.org>.
> Signed-off-by: Sascha Silbe <silbe@activitycentral.com>
> ---
>  drivers/net/wireless/libertas/main.c |    9 ++++++++-
>  1 files changed, 8 insertions(+), 1 deletions(-)
> 
> The patch is based on the OLPC 2.6.35 kernel tree, but applies cleanly to
> wireless-next.
> 
> diff --git a/drivers/net/wireless/libertas/main.c b/drivers/net/wireless/libertas/main.c
> index 8445473..62069e2 100644
> --- a/drivers/net/wireless/libertas/main.c
> +++ b/drivers/net/wireless/libertas/main.c
> @@ -41,6 +41,10 @@ unsigned int lbs_debug;
>  EXPORT_SYMBOL_GPL(lbs_debug);
>  module_param_named(libertas_debug, lbs_debug, int, 0644);
> 
> +unsigned int lbs_disablemesh;
> +EXPORT_SYMBOL_GPL(lbs_disablemesh);
> +module_param_named(libertas_disablemesh, lbs_disablemesh, int, 0644);
> +
> 
>  /* This global structure is used to send the confirm_sleep command as
>   * fast as possible down to the firmware. */
> @@ -1086,7 +1090,10 @@ int lbs_start_card(struct lbs_private *priv)
> 
>  	lbs_update_channel(priv);
> 
> -	lbs_init_mesh(priv);
> +	if (!lbs_disablemesh)
> +		lbs_init_mesh(priv);
> +	else
> +		lbs_pr_info("%s: mesh disabled\n", dev->name);
> 
>  	/*
>  	 * While rtap isn't related to mesh, only mesh-enabled
> --
> 1.7.4.1
> 
