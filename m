From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH] net: ethernet: ti: davinci_cpdma: free memory while
 channel destroy
Date: Tue, 8 Nov 2016 17:22:09 -0600
Message-ID: <366a66b8-33f4-2ad7-4ac4-957d25348718@ti.com>
References: <1478610965-25288-1-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-omap@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
        <mugunthanvnm@ti.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:47337 "EHLO
        devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751062AbcKHXWL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2016 18:22:11 -0500
In-Reply-To: <1478610965-25288-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 11/08/2016 07:16 AM, Ivan Khoronzhuk wrote:
> While create/destroy channel operation memory is not freed. It was
> supposed that memory is freed while driver remove. But a channel
> can be created and destroyed many times while changing number of
> channels with ethtool.
>
> Based on net-next/master

^?

>
> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>

Reviewed-by: Grygorii Strashko <grygorii.strashko@ti.com>

> ---
>  drivers/net/ethernet/ti/davinci_cpdma.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
> index 05afc05..07fc92d 100644
> --- a/drivers/net/ethernet/ti/davinci_cpdma.c
> +++ b/drivers/net/ethernet/ti/davinci_cpdma.c
> @@ -586,7 +586,7 @@ int cpdma_chan_destroy(struct cpdma_chan *chan)
>  		cpdma_chan_stop(chan);
>  	ctlr->channels[chan->chan_num] = NULL;
>  	ctlr->chan_num--;
> -
> +	devm_kfree(ctlr->dev, chan);
>  	cpdma_chan_split_pool(ctlr);
>
>  	spin_unlock_irqrestore(&ctlr->lock, flags);
>

-- 
regards,
-grygorii
