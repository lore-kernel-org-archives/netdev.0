From: Peppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH] stmmac: fix stmmac_resume removing not yet used
 shutdown flag
Date: Fri, 26 Nov 2010 15:16:43 +0100
Message-ID: <4CEFC14B.70806@st.com>
References: <1290740072-1341-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: "vlad.lungu@windriver.com" <vlad.lungu@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:38466 "EHLO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751043Ab0KZORG convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Nov 2010 09:17:06 -0500
In-Reply-To: <1290740072-1341-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/26/2010 3:11 PM, Peppe CAVALLARO wrote:
> The commit to convert to use the dev_pm_ops struct
> introduces a bug. The shutdown flag is not yet used
> because the hibernation on memory is done by using
> the freeze callback.
> Thanks to Vlad for having reported it.
Hi Vlad,
as we discussed via email, I'll also look at how to manage the
patch that reworked the private structure and that's generating
problems on your HW (I'll also try to have it for testing!).

Many thanks for the feedback and for having spotted this issue (sorry!).

Regards,
Peppe
> Reported-by: Vlad Lungu <vlad.lungu@windriver.com>
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> ---
>  drivers/net/stmmac/stmmac_main.c |    7 -------
>  1 files changed, 0 insertions(+), 7 deletions(-)
>
> diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
> index f1dbc18..730a6fd 100644
> --- a/drivers/net/stmmac/stmmac_main.c
> +++ b/drivers/net/stmmac/stmmac_main.c
> @@ -1846,13 +1846,6 @@ static int stmmac_resume(struct device *dev)
>  	if (!netif_running(ndev))
>  		return 0;
>  
> -	if (priv->shutdown) {
> -		/* Re-open the interface and re-init the MAC/DMA
> -		   and the rings (i.e. on hibernation stage) */
> -		stmmac_open(dev);
> -		return 0;
> -	}
> -
>  	spin_lock(&priv->lock);
>  
>  	/* Power Down bit, into the PM register, is cleared
