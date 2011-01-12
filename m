From: Peppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 10/16] drivers/net: stmmac: don't treat NULL clk as an
 error
Date: Wed, 12 Jan 2011 09:00:35 +0100
Message-ID: <4D2D5FA3.507@st.com>
References: <1294749833-32019-1-git-send-email-jamie@jamieiles.com>
 <1294749833-32019-11-git-send-email-jamie@jamieiles.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jamie Iles <jamie@jamieiles.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog119.obsmtp.com ([207.126.144.147]:58208 "EHLO
	eu1sys200aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755325Ab1ALIBT convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jan 2011 03:01:19 -0500
In-Reply-To: <1294749833-32019-11-git-send-email-jamie@jamieiles.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello

On 1/11/2011 1:43 PM, Jamie Iles wrote:
>
> clk_get() returns a struct clk cookie to the driver and some platforms
> may return NULL if they only support a single clock.  clk_get() has only
> failed if it returns a ERR_PTR() encoded pointer.
>
Thanks for the patch that actually useful.
I'm going to rework this part of the driver.
At any rate, all my new changes can be done on top of this patch.

Regards,
Peppe
>
>
> Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Jamie Iles <jamie@jamieiles.com>
> ---
>  drivers/net/stmmac/stmmac_timer.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/stmmac/stmmac_timer.c
> b/drivers/net/stmmac/stmmac_timer.c
> index 2a0e1ab..ebb1b37 100644
> --- a/drivers/net/stmmac/stmmac_timer.c
> +++ b/drivers/net/stmmac/stmmac_timer.c
> @@ -91,6 +91,7 @@ int stmmac_close_ext_timer(void)
>
>  #elif defined(CONFIG_STMMAC_TMU_TIMER)
>  #include <linux/clk.h>
> +#include <linux/err.h>
>  #define TMU_CHANNEL "tmu2_clk"
>  static struct clk *timer_clock;
>
> @@ -109,7 +110,7 @@ int stmmac_open_ext_timer(struct net_device *dev,
> struct stmmac_timer *tm)
>  {
>         timer_clock = clk_get(NULL, TMU_CHANNEL);
>
> -       if (timer_clock == NULL)
> +       if (IS_ERR(timer_clock))
>                 return -1;
>
>         if (tmu2_register_user(stmmac_timer_handler, (void *)dev) < 0) {
> --
> 1.7.3.4
>
