From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] SGISEEQ: fix oops when doing ifconfig down; ifconfig
 up
Date: Fri, 18 Jan 2008 15:01:49 -0500
Message-ID: <479105AD.6060201@garzik.org>
References: <20080112230847.1EB3EC2F35@solo.franken.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org,
	ralf@linux-mips.org, jgarzik@pobox.com
To: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <20080112230847.1EB3EC2F35@solo.franken.de>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

Thomas Bogendoerfer wrote:
> When doing init_ring checking whether a new skb needs to be allocated
> was wrong.
> 
> Signed-off-by: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
> ---
> 
> This is a bug fix for the 2.6.25 driver.
> 
>  drivers/net/sgiseeq.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/sgiseeq.c b/drivers/net/sgiseeq.c
> index c69bb8b..78994ed 100644
> --- a/drivers/net/sgiseeq.c
> +++ b/drivers/net/sgiseeq.c
> @@ -193,7 +193,7 @@ static int seeq_init_ring(struct net_device *dev)
>  
>  	/* And now the rx ring. */
>  	for (i = 0; i < SEEQ_RX_BUFFERS; i++) {
> -		if (!sp->rx_desc[i].rdma.pbuf) {
> +		if (!sp->rx_desc[i].skb) {
>  			dma_addr_t dma_addr;
>  			struct sk_buff *skb = netdev_alloc_skb(dev, PKT_BUF_SZ);

applied
