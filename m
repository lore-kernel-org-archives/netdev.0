From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH] stmmac: fix return value check in stmmac_open_ext_timer()
Date: Fri, 21 Sep 2012 10:21:30 +0200
Message-ID: <505C238A.5050301@st.com>
References: <CAPgLHd87SqVa40-SGrgEfRAPWj1dr9aGPDD7b3aALCqka2ssuA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog107.obsmtp.com ([207.126.144.123]:42145 "EHLO
	eu1sys200aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753491Ab2IUIVp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 04:21:45 -0400
In-Reply-To: <CAPgLHd87SqVa40-SGrgEfRAPWj1dr9aGPDD7b3aALCqka2ssuA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/21/2012 9:06 AM, Wei Yongjun wrote:
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>
> In case of error, the function clk_get() returns ERR_PTR()
> and never returns NULL pointer. The NULL test in the error
> handling should be replaced with IS_ERR().
>
> dpatch engine is used to auto generated this patch.
> (https://github.com/weiyj/dpatch)

FYI I have recently sent some patches (still under reviewing) to 
completely remove this dead code from the driver.

http://marc.info/?l=linux-netdev&m=134734656020277&w=2

Peppe

> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> ---
>   drivers/net/ethernet/stmicro/stmmac/stmmac_timer.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_timer.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_timer.c
> index 2a0e1ab..197fb8c 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_timer.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_timer.c
> @@ -109,7 +109,7 @@ int stmmac_open_ext_timer(struct net_device *dev, struct stmmac_timer *tm)
>   {
>   	timer_clock = clk_get(NULL, TMU_CHANNEL);
>
> -	if (timer_clock == NULL)
> +	if (IS_ERR(timer_clock))
>   		return -1;
>
>   	if (tmu2_register_user(stmmac_timer_handler, (void *)dev) < 0) {
>
>
>
