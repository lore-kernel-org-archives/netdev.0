From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: [PATCH -mm] ath5k: remove sysctl(2) support
Date: Thu, 23 Aug 2007 22:22:35 +0200
Message-ID: <46CDEC8B.7080007@gmail.com>
References: <20070823083351.GA31289@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, linville@tuxdriver.com, netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:63331 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752278AbXHWUVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2007 16:21:39 -0400
Received: by nf-out-0910.google.com with SMTP id g13so461259nfb
        for <netdev@vger.kernel.org>; Thu, 23 Aug 2007 13:21:38 -0700 (PDT)
In-Reply-To: <20070823083351.GA31289@localhost.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Dobriyan napsal(a):
> sysctl(2) is supported but frozen.

I've posted similar patch yesterday:
http://marc.info/?l=linux-mm-commits&m=118782442602108&w=2

> Signed-off-by: Alexey Dobriyan <adobriyan@sw.ru>
> ---
> 
>  drivers/net/wireless/ath5k_base.c |   21 ++++++---------------
>  1 file changed, 6 insertions(+), 15 deletions(-)
> 
> --- a/drivers/net/wireless/ath5k_base.c
> +++ b/drivers/net/wireless/ath5k_base.c
> @@ -2438,21 +2438,12 @@ static struct pci_driver ath_pci_drv_id = {
>  	.resume		= ath_pci_resume,
>  };
>  
> -/*
> - * Static (i.e. global) sysctls.  Note that the hal sysctls
> - * are located under ours by sharing the setting for DEV_ATH.
> - */
> -enum {
> -	DEV_ATH		= 9,			/* XXX known by hal */
> -};
> -
>  static int mincalibrate = 1;
>  static int maxcalibrate = INT_MAX / 1000;
> -#define	CTL_AUTO	-2	/* cannot be CTL_ANY or CTL_NONE */
>  
>  static ctl_table ath_static_sysctls[] = {
>  #if AR_DEBUG
> -	{ .ctl_name	= CTL_AUTO,
> +	{
>  	  .procname	= "debug",
>  	  .mode		= 0644,
>  	  .data		= &ath_debug,
> @@ -2460,28 +2451,28 @@ static ctl_table ath_static_sysctls[] = {
>  	  .proc_handler	= proc_dointvec
>  	},
>  #endif
> -	{ .ctl_name	= CTL_AUTO,
> +	{
>  	  .procname	= "countrycode",
>  	  .mode		= 0444,
>  	  .data		= &countrycode,
>  	  .maxlen	= sizeof(countrycode),
>  	  .proc_handler	= proc_dointvec
>  	},
> -	{ .ctl_name	= CTL_AUTO,
> +	{
>  	  .procname	= "outdoor",
>  	  .mode		= 0444,
>  	  .data		= &outdoor,
>  	  .maxlen	= sizeof(outdoor),
>  	  .proc_handler	= proc_dointvec
>  	},
> -	{ .ctl_name	= CTL_AUTO,
> +	{
>  	  .procname	= "xchanmode",
>  	  .mode		= 0444,
>  	  .data		= &xchanmode,
>  	  .maxlen	= sizeof(xchanmode),
>  	  .proc_handler	= proc_dointvec
>  	},
> -	{ .ctl_name	= CTL_AUTO,
> +	{
>  	  .procname	= "calibrate",
>  	  .mode		= 0644,
>  	  .data		= &ath_calinterval,
> @@ -2493,7 +2484,7 @@ static ctl_table ath_static_sysctls[] = {
>  	{ 0 }
>  };
>  static ctl_table ath_ath_table[] = {
> -	{ .ctl_name	= DEV_ATH,
> +	{
>  	  .procname	= "ath",
>  	  .mode		= 0555,
>  	  .child	= ath_static_sysctls

Anyway thanks!

-- 
Jiri Slaby (jirislaby@gmail.com)
Faculty of Informatics, Masaryk University
