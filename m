From: Luis Henriques <luis.henriques@canonical.com>
Subject: Re: [net PATCH] atl1c: Fix misuse of netdev_alloc_skb in refilling rx ring
Date: Fri, 26 Jul 2013 17:56:16 +0100
Message-ID: <8761vxfefj.fsf@canonical.com>
References: <1374857234-1442-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, Jay Cliburn <jcliburn@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, stable@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1374857234-1442-1-git-send-email-nhorman@tuxdriver.com> (Neil
	Horman's message of "Fri, 26 Jul 2013 12:47:14 -0400")
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Neil Horman <nhorman@tuxdriver.com> writes:

> atl1c uses netdev_alloc_skb to refill its rx dma ring, but that call makes no
> guarantees about the suitability of the memory for use in DMA.  As a result
> we've gotten reports of atl1c drivers occasionally hanging and needing to be
> reset:
> https://bugzilla.kernel.org/show_bug.cgi?id=54021
>
> Fix this by modifying the call to use the internal version __netdev_alloc_skb,
> where you can set the gfp_mask explicitly to include GFP_DMA.
>
> Tested by two reporters in the above bug, who have the hardware to validate it.
> Both report immediate cessation of the problem with this patch
>
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> CC: Jay Cliburn <jcliburn@gmail.com>
> CC: "David S. Miller" <davem@davemloft.net>
> CC: stable@vger.kernel.org
> Tested-by: Luis Henrix <luis.henrix@gmail.com>

Thanks Neil!

Would it be possible for you to update my name and email?  (I've just
updated my bz account to remove my gmail account address -- I thought
I had done this ages ago.)

Tested-by: Luis Henriques <luis.henriques@canonical.com>

Cheers,
-- 
Luis


> Tested-by: Vincent Alquier <vincent.alquier@gmail.com> ---
> drivers/net/ethernet/atheros/atl1c/atl1c_main.c | 2 +- 1 file
> changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
> index 786a874..d5e38d1 100644
> --- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
> +++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
> @@ -1660,7 +1660,7 @@ static int atl1c_alloc_rx_buffer(struct atl1c_adapter *adapter)
>  	while (next_info->flags & ATL1C_BUFFER_FREE) {
>  		rfd_desc = ATL1C_RFD_DESC(rfd_ring, rfd_next_to_use);
>  
> -		skb = netdev_alloc_skb(adapter->netdev, adapter->rx_buffer_len);
> +		skb = __netdev_alloc_skb(adapter->netdev, adapter->rx_buffer_len, GFP_ATOMIC|GFP_DMA);
>  		if (unlikely(!skb)) {
>  			if (netif_msg_rx_err(adapter))
>  				dev_warn(&pdev->dev, "alloc rx buffer failed\n");
