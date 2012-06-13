From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next.git 2/4 (v2)] stmmac: do not use strict_strtoul but
 kstrtoul
Date: Wed, 13 Jun 2012 09:32:07 +0200
Message-ID: <1339572727.22704.314.camel@edumazet-glaptop>
References: <1339571827-7162-1-git-send-email-peppe.cavallaro@st.com>
	 <1339571827-7162-3-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	rayagond@vayavyalabs.com, davem@davemloft.net,
	yuvalmin@broadcom.com
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:33517 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750778Ab2FMHcN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2012 03:32:13 -0400
Received: by eaak11 with SMTP id k11so64893eaa.19
        for <netdev@vger.kernel.org>; Wed, 13 Jun 2012 00:32:12 -0700 (PDT)
In-Reply-To: <1339571827-7162-3-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-13 at 09:17 +0200, Giuseppe CAVALLARO wrote:
> This patch replaces the obsolete strict_strtoul with kstrtoul.
> 
> v2: also removed casting on kstrtoul.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac.h      |    2 +-
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   67 +++++++++-----------
>  2 files changed, 31 insertions(+), 38 deletions(-)
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
> index 6d07ba2..1d70f64 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
> @@ -88,7 +88,7 @@ struct stmmac_priv {
>  	int synopsys_id;
>  };
>  
> -extern int phyaddr;
> +extern unsigned long int phyaddr;
>  
>  extern int stmmac_mdio_unregister(struct net_device *ndev);
>  extern int stmmac_mdio_register(struct net_device *ndev);
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 8899e10..bd53003 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -80,39 +80,39 @@
>  
>  /* Module parameters */
>  #define TX_TIMEO 5000 /* default 5 seconds */
> -static int watchdog = TX_TIMEO;
> -module_param(watchdog, int, S_IRUGO | S_IWUSR);
> +static unsigned long int watchdog = TX_TIMEO;
> +module_param(watchdog, ulong, S_IRUGO | S_IWUSR);
>  MODULE_PARM_DESC(watchdog, "Transmit timeout in milliseconds");
>  

It seems you missed the kstrtouint() / kstrtoint() functions....
