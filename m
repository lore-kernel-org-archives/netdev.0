From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH] net: ethernet: ti: cpdma: use desc_read in chan_process
 instead of raw read
Date: Mon, 5 Dec 2016 12:47:16 -0600
Message-ID: <ed16f5d1-8e5b-470f-1566-4129eef47ee1@ti.com>
References: <1480730715-16000-1-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-omap@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>, <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480730715-16000-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 12/02/2016 08:05 PM, Ivan Khoronzhuk wrote:
> There is desc_read() macros to read desc fields, so no need to
> use __raw_readl();
>
> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>


I'm going to update it all at once as part of [1].

[1] https://lkml.org/lkml/2016/12/1/781

> ---
> Based on net-next/master
>
>  drivers/net/ethernet/ti/davinci_cpdma.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
> index c776e45..d96dca5 100644
> --- a/drivers/net/ethernet/ti/davinci_cpdma.c
> +++ b/drivers/net/ethernet/ti/davinci_cpdma.c
> @@ -1132,7 +1132,7 @@ static int __cpdma_chan_process(struct cpdma_chan *chan)
>  	}
>  	desc_dma = desc_phys(pool, desc);
>
> -	status	= __raw_readl(&desc->hw_mode);
> +	status = desc_read(desc, hw_mode);
>  	outlen	= status & 0x7ff;
>  	if (status & CPDMA_DESC_OWNER) {
>  		chan->stats.busy_dequeue++;
>

-- 
regards,
-grygorii
