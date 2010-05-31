From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] ixp4xx: Support the all multicast flag on the NPE devices.
Date: Mon, 31 May 2010 16:09:13 +0200
Message-ID: <m3pr0c17ue.fsf@intrepid.localdomain>
References: <20100531131102.GA15870@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20100531131102.GA15870@riccoc20.at.omicron.at> (Richard
	Cochran's message of "Mon, 31 May 2010 15:11:02 +0200")
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Richard Cochran <richardcochran@gmail.com> writes:

> This patch adds support for the IFF_ALLMULTI flag. Previously only the
> IFF_PROMISC flag was supported.
>
> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
> ---
>  drivers/net/arm/ixp4xx_eth.c |   11 +++++++++++
>  1 files changed, 11 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/arm/ixp4xx_eth.c b/drivers/net/arm/ixp4xx_eth.c
> index 6be8b09..5d35064 100644
> --- a/drivers/net/arm/ixp4xx_eth.c
> +++ b/drivers/net/arm/ixp4xx_eth.c
> @@ -739,6 +739,17 @@ static void eth_set_mcast_list(struct net_device *dev)
>  	struct dev_mc_list *mclist;
>  	u8 diffs[ETH_ALEN], *addr;
>  	int i;
> +	u8 allmulti[] = { 0x01, 0x00, 0x00, 0x00, 0x00, 0x00 };
> +
> +	if (dev->flags & IFF_ALLMULTI) {
> +		for (i = 0; i < ETH_ALEN; i++) {
> +			__raw_writel(allmulti[i], &port->regs->mcast_addr[i]);
> +			__raw_writel(allmulti[i], &port->regs->mcast_mask[i]);
> +		}
> +		__raw_writel(DEFAULT_RX_CNTRL0 | RX_CNTRL0_ADDR_FLTR_EN,
> +			&port->regs->rx_control[0]);
> +		return;
> +	}

Looks good, though I'd prefer a bit of "const" and "static" in the
allmulti[] declaration. Would you please repost? TIA.
-- 
Krzysztof Halasa
