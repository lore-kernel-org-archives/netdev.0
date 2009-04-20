From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH]8390p: Get rid of init_module/cleanup_module
Date: Mon, 20 Apr 2009 17:46:19 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.0904201744380.13028@wotan.suse.de>
References: <667b0cb60904110555k442f3959k9140d355b00980cd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	p_gortmaker@yahoo.com, trivial@kernel.org, netdev@vger.kernel.org
To: Mateusz Mandera <ormi.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:37151 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755834AbZDTPqV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Apr 2009 11:46:21 -0400
In-Reply-To: <667b0cb60904110555k442f3959k9140d355b00980cd@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 11 Apr 2009, Mateusz Mandera wrote:

> This trivial patch just "gets rid of" init_module and cleanup_module
> from drivers/net/8390p.c
> 
> Signed-off-by: Mateusz Mandera <ormi.linux@gmail.com>
> ---
> diff --git a/drivers/net/8390p.c b/drivers/net/8390p.c
> index da863c9..ec9e3ca 100644
> --- a/drivers/net/8390p.c
> +++ b/drivers/net/8390p.c
> @@ -97,16 +97,15 @@ void NS8390p_init(struct net_device *dev, int startp)
>  }
>  EXPORT_SYMBOL(NS8390p_init);
> 
> -#if defined(MODULE)
> -
> -int init_module(void)
> +static int __init 8390p_init_module(void)
>  {
>  	return 0;
>  }
> 
> -void cleanup_module(void)
> +static void __exit 8390p_cleanup_module(void)
>  {
>  }
> 
> -#endif /* MODULE */
> +module_init(8390p_init_module);
> +module_exit(8390p_cleanup_module);
>  MODULE_LICENSE("GPL");

I'd rather have this merged through subsystem tree than trivial tree, 
adding netdev to CC.

-- 
Jiri Kosina
SUSE Labs
