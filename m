From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v2 11/20] net: packetengines: slight optimization
 of addr
Date: Sat, 28 Dec 2013 17:58:05 +0400
Message-ID: <52BED8ED.2040908@cogentembedded.com>
References: <52BE6D0D.9050301@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Ding Tianhong <dingtianhong@huawei.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52BE6D0D.9050301@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 28-12-2013 10:17, Ding Tianhong wrote:

> Use possibly more efficient ether_addr_equal
> to instead of memcmp.

> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> ---
>   drivers/net/ethernet/packetengines/yellowfin.c |   12 ++++++------
>   1 files changed, 6 insertions(+), 6 deletions(-)

> diff --git a/drivers/net/ethernet/packetengines/yellowfin.c b/drivers/net/ethernet/packetengines/yellowfin.c
> index d28593b..b83ac0e 100644
> --- a/drivers/net/ethernet/packetengines/yellowfin.c
> +++ b/drivers/net/ethernet/packetengines/yellowfin.c
> @@ -1097,12 +1097,12 @@ static int yellowfin_rx(struct net_device *dev)
>   			if (status2 & 0x80) dev->stats.rx_dropped++;
>   #ifdef YF_PROTOTYPE		/* Support for prototype hardware errata. */
>   		} else if ((yp->flags & HasMACAddrBug)  &&
> -			memcmp(le32_to_cpu(yp->rx_ring_dma +
> -				entry*sizeof(struct yellowfin_desc)),
> -				dev->dev_addr, 6) != 0 &&
> -			memcmp(le32_to_cpu(yp->rx_ring_dma +
> -				entry*sizeof(struct yellowfin_desc)),
> -				"\377\377\377\377\377\377", 6) != 0) {
> +			!ether_addr_equal(le32_to_cpu(yp->rx_ring_dma +
> +						      entry * sizeof(struct yellowfin_desc)),
> +							  dev->dev_addr) &&

    Previous line was aligned correctly, the above line should start under 
le32_to_cpu.

> +			!ether_addr_equal(le32_to_cpu(yp->rx_ring_dma +
> +							  entry * sizeof(struct yellowfin_desc)),

    Start the continuation lines under 'yp', please.

> +							  "\377\377\377\377\377\377")) {

    This line should start under le32_to_cpu.

WBR, Sergei
