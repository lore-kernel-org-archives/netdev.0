From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH 1/2] [net/wireless/iwlwifi] : iwlwifi 3945 Fix
 raceconditional panic.
Date: Wed, 12 Dec 2007 03:43:25 -0800
Message-ID: <20071212034325.4a022320.akpm@linux-foundation.org>
References: <00e501c831ab$2e78daa0$9c94fea9@jason>
	<1196298656.7614.77.camel@debian.sh.intel.com>
	<016401c83229$3302d250$9c94fea9@jason>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "'Zhu Yi'" <yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	<ipw3945-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Joonwoo Park" <joonwpark81-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <016401c83229$3302d250$9c94fea9@jason>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 29 Nov 2007 10:42:49 +0900 "Joonwoo Park" <joonwpark81-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> 2007/11/29, Zhu Yi <yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>:
> > 
> > Good catch. But it will be better if you add it into
> > iwl_cancel_deferred_work().
> > 
> 
> Thanks.
> I agree with you. 
> Actually, I considered it, but I was afraid of side effect.
> Anyway, I'm attaching a new one.
> 
> Thanks.
> Joonwoo
> 
> [net/wireless/iwlwifi] : iwlwifi 3945 Fix race conditional panic.
> 
> Signed-off-by: Joonwoo Park <joonwpark81-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
> diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
> index 465da4f..e51e872 100644
> --- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
> +++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
> @@ -8270,6 +8270,7 @@ static void iwl_cancel_deferred_work(struct iwl_priv *priv)
>  {
>  	iwl_hw_cancel_deferred_work(priv);
>  
> +	cancel_delayed_work_sync(&priv->init_alive_start);
>  	cancel_delayed_work(&priv->scan_check);
>  	cancel_delayed_work(&priv->alive_start);
>  	cancel_delayed_work(&priv->post_associate);

Did drivers/net/wireless/iwlwifi/iwl4965-base.c get fixed in a simlar
fashion?
