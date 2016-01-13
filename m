From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next] hip04_eth: fix missing error handle for build_skb
 failed
Date: Wed, 13 Jan 2016 11:48:41 +0800
Message-ID: <5695C919.8070203@huawei.com>
References: <5695C04D.1070709@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Weidong Wang <wangweidong1@huawei.com>,
	David Miller <davem@davemloft.net>, <arnd@arndb.de>,
	<zhangfei.gao@linaro.org>, <dan.carpenter@oracle.com>,
	<tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5695C04D.1070709@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016/1/13 11:11, Weidong Wang wrote:
> when build_skb failed, we should goto refill the buffer.
> 
> Signed-off-by: Weidong Wang <wangweidong1@huawei.com>
> ---

Acked-by: Ding Tainhong <dingtianhong@huawei.com>

>  drivers/net/ethernet/hisilicon/hip04_eth.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/hisilicon/hip04_eth.c b/drivers/net/ethernet/hisilicon/hip04_eth.c
> index 3b39fdd..417f131 100644
> --- a/drivers/net/ethernet/hisilicon/hip04_eth.c
> +++ b/drivers/net/ethernet/hisilicon/hip04_eth.c
> @@ -500,8 +500,10 @@ static int hip04_rx_poll(struct napi_struct *napi, int budget)
>  	while (cnt && !last) {
>  		buf = priv->rx_buf[priv->rx_head];
>  		skb = build_skb(buf, priv->rx_buf_size);
> -		if (unlikely(!skb))
> +		if (unlikely(!skb)) {
>  			net_dbg_ratelimited("build_skb failed\n");
> +			goto refill;
> +		}
> 
>  		dma_unmap_single(&ndev->dev, priv->rx_phys[priv->rx_head],
>  				 RX_BUF_SIZE, DMA_FROM_DEVICE);
> @@ -528,6 +530,7 @@ static int hip04_rx_poll(struct napi_struct *napi, int budget)
>  			rx++;
>  		}
> 
> +refill:
>  		buf = netdev_alloc_frag(priv->rx_buf_size);
>  		if (!buf)
>  			goto done;
> 
