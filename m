From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: bgmac: fix a missing check for build_skb
Date: Wed, 13 Jan 2016 15:10:12 +0300
Message-ID: <56963EA4.1040704@cogentembedded.com>
References: <5695BF41.2040002@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Weidong Wang <wangweidong1@huawei.com>,
	David Miller <davem@davemloft.net>, nbd@openwrt.org,
	zajec5@gmail.com, hauke@hauke-m.de, Joe Perches <joe@perches.com>,
	peter.senna@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5695BF41.2040002@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 1/13/2016 6:06 AM, Weidong Wang wrote:

> when build_skb failed, it may occure a NULL pointer.
> So add a 'NULL check' for it.
>
> Signed-off-by: Weidong Wang <wangweidong1@huawei.com>
> ---
>   drivers/net/ethernet/broadcom/bgmac.c | 5 +++++
>   1 file changed, 5 insertions(+)
>
> diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
> index 21e3c38..d75180a 100644
> --- a/drivers/net/ethernet/broadcom/bgmac.c
> +++ b/drivers/net/ethernet/broadcom/bgmac.c
> @@ -466,6 +466,11 @@ static int bgmac_dma_rx_read(struct bgmac *bgmac, struct bgmac_dma_ring *ring,
>   			len -= ETH_FCS_LEN;
>
>   			skb = build_skb(buf, BGMAC_RX_ALLOC_SIZE);
> +			if (unlikely(skb)) {

    !skb , you mean?

> +				bgmac_err(bgmac, "build_skb failed\n");
> +				put_page(virt_to_head_page(buf));
> +				break;
> +			}
>   			skb_put(skb, BGMAC_RX_FRAME_OFFSET +
>   				BGMAC_RX_BUF_OFFSET + len);
>   			skb_pull(skb, BGMAC_RX_FRAME_OFFSET +

MBR, Sergei
