From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 5/9] net: dsa: Export suspend/resume functions
Date: Sat, 4 Jun 2016 22:30:39 +0200
Message-ID: <20160604203039.GG2063@lunn.ch>
References: <1464998733-10405-1-git-send-email-f.fainelli@gmail.com>
 <1464998733-10405-8-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com, john@phrozen.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59643 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750950AbcFDUal (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Jun 2016 16:30:41 -0400
Content-Disposition: inline
In-Reply-To: <1464998733-10405-8-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 03, 2016 at 05:05:27PM -0700, Florian Fainelli wrote:
> In preparation for allowing switch drivers to implement system-wide
> suspend/resume functions, export dsa_switch_suspend and
> dsa_switch_resume() such that these are callable from the appropriate
> driver specific suspend/resume functions.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

     Andrew

> ---
>  include/net/dsa.h | 14 ++++++++++++++
>  net/dsa/dsa.c     |  6 ++++--
>  2 files changed, 18 insertions(+), 2 deletions(-)
> 
> diff --git a/include/net/dsa.h b/include/net/dsa.h
> index d6ed5dee73e5..c5abaeda84f3 100644
> --- a/include/net/dsa.h
> +++ b/include/net/dsa.h
> @@ -382,4 +382,18 @@ static inline bool dsa_uses_tagged_protocol(struct dsa_switch_tree *dst)
>  
>  void dsa_unregister_switch(struct dsa_switch *ds);
>  int dsa_register_switch(struct dsa_switch *ds, struct device_node *np);
> +#ifdef CONFIG_PM_SLEEP
> +int dsa_switch_suspend(struct dsa_switch *ds);
> +int dsa_switch_resume(struct dsa_switch *ds);
> +#else
> +static inline int dsa_switch_suspend(struct dsa_switch *ds)
> +{
> +	return 0;
> +}
> +static inline int dsa_switch_resume(struct dsa_switch *ds)
> +{
> +	return 0;
> +}
> +#endif /* CONFIG_PM_SLEEP */
> +
>  #endif
> diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
> index d8cb2acd4f0a..ebc29a1bee08 100644
> --- a/net/dsa/dsa.c
> +++ b/net/dsa/dsa.c
> @@ -500,7 +500,7 @@ static void dsa_switch_destroy(struct dsa_switch *ds)
>  }
>  
>  #ifdef CONFIG_PM_SLEEP
> -static int dsa_switch_suspend(struct dsa_switch *ds)
> +int dsa_switch_suspend(struct dsa_switch *ds)
>  {
>  	int i, ret = 0;
>  
> @@ -519,8 +519,9 @@ static int dsa_switch_suspend(struct dsa_switch *ds)
>  
>  	return ret;
>  }
> +EXPORT_SYMBOL_GPL(dsa_switch_suspend);
>  
> -static int dsa_switch_resume(struct dsa_switch *ds)
> +int dsa_switch_resume(struct dsa_switch *ds)
>  {
>  	int i, ret = 0;
>  
> @@ -542,6 +543,7 @@ static int dsa_switch_resume(struct dsa_switch *ds)
>  
>  	return 0;
>  }
> +EXPORT_SYMBOL_GPL(dsa_switch_resume);
>  #endif
>  
>  /* platform driver init and cleanup *****************************************/
> -- 
> 2.7.4
> 
