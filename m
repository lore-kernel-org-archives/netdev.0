From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next.git 2/4] stmmac: do not use strict_strtoul but
 kstrtoul
Date: Tue, 12 Jun 2012 16:28:01 +0200
Message-ID: <1339511281.22704.156.camel@edumazet-glaptop>
References: <1339505153-26731-1-git-send-email-peppe.cavallaro@st.com>
	 <1339505153-26731-3-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	rayagond@vayavyalabs.com, davem@davemloft.net,
	yuvalmin@broadcom.com
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:44675 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752530Ab2FLO2H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2012 10:28:07 -0400
Received: by eaak11 with SMTP id k11so2211298eaa.19
        for <netdev@vger.kernel.org>; Tue, 12 Jun 2012 07:28:06 -0700 (PDT)
In-Reply-To: <1339505153-26731-3-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-12 at 14:45 +0200, Giuseppe CAVALLARO wrote:
> This patch replaces the obsolete strict_strtoul with kstrtoul.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   26 ++++++++-------------
>  1 files changed, 10 insertions(+), 16 deletions(-)
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 8899e10..e33abf5 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -2126,42 +2126,36 @@ static int __init stmmac_cmdline_opt(char *str)
>  		return -EINVAL;
>  	while ((opt = strsep(&str, ",")) != NULL) {
>  		if (!strncmp(opt, "debug:", 6)) {
> -			if (strict_strtoul(opt + 6, 0, (unsigned long *)&debug))
> +			if (kstrtoul(opt + 6, 0, (unsigned long *)&debug))
>  				goto err;


int debug;
...
if (kstrtoul(opt + 6, 0, (unsigned long *)&debug))

Please get rid of these wrong casts.
