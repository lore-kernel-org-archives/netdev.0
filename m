From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [patch net-next] hisilicon: add some missing curly braces
Date: Thu, 29 Jan 2015 10:50:35 +0800
Message-ID: <54C99FFB.2080207@huawei.com>
References: <20150128185833.GA10259@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Zhangfei Gao <zhangfei.gao@linaro.org>,
	"David S. Miller" <davem@davemloft.net>,
	Arnd Bergmann <arnd@arndb.de>, <netdev@vger.kernel.org>,
	<kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:18866 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755086AbbA2Cuw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2015 21:50:52 -0500
In-Reply-To: <20150128185833.GA10259@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015/1/29 2:58, Dan Carpenter wrote:
> The if block was supposed to have curly braces.  In the current code we
> complain about dropped rx packets when we shouldn't.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
Acked-by: Ding Tianhong <dingtianhong@huawei.com>

Good catch. thanks;

Hi David, this patch looks good to me, and I was preparing a series patches for hip04,
I could add this patch to the series or you could apply this alone as your wish.:)

Ding

> diff --git a/drivers/net/ethernet/hisilicon/hip04_eth.c b/drivers/net/ethernet/hisilicon/hip04_eth.c
> index 525214e..c02b81b 100644
> --- a/drivers/net/ethernet/hisilicon/hip04_eth.c
> +++ b/drivers/net/ethernet/hisilicon/hip04_eth.c
> @@ -567,10 +567,11 @@ static irqreturn_t hip04_mac_interrupt(int irq, void *dev_id)
>  	writel_relaxed(DEF_INT_MASK, priv->base + PPE_RINT);
>  
>  	if (unlikely(ists & DEF_INT_ERR)) {
> -		if (ists & (RCV_NOBUF | RCV_DROP))
> +		if (ists & (RCV_NOBUF | RCV_DROP)) {
>  			stats->rx_errors++;
>  			stats->rx_dropped++;
>  			netdev_err(ndev, "rx drop\n");
> +		}
>  		if (ists & TX_DROP) {
>  			stats->tx_dropped++;
>  			netdev_err(ndev, "tx drop\n");
> 
> 
