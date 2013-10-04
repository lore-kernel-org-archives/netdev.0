From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 02/10] qlcnic: Enhance ethtool to display ring
 indices and interrupt mask
Date: Fri, 4 Oct 2013 21:37:41 +0100
Message-ID: <1380919061.3214.13.camel@bwh-desktop.uk.level5networks.com>
References: <cover.1380937706.git.himanshu.madhani@qlogic.com>
	 <6802e3c08711090eada36dead165ab931c4e61db.1380937706.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Pratik Pujar <pratik.pujar@qlogic.com>
To: Himanshu Madhani <himanshu.madhani@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:45238 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751577Ab3JDUhq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Oct 2013 16:37:46 -0400
In-Reply-To: <6802e3c08711090eada36dead165ab931c4e61db.1380937706.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-10-04 at 14:30 -0400, Himanshu Madhani wrote:
> From: Pratik Pujar <pratik.pujar@qlogic.com>
> 
> o Updated ethtool -d <ethX> option to display ring indices for Transmit(Tx),
>   Receive(Rx), and Status(St) rings.
> o Updated ethtool -d <ethX> option to display ring interrupt mask for Transmit(Tx),
>   and Status(St) rings.
> 
> Signed-off-by: Pratik Pujar <pratik.pujar@qlogic.com>
> Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
> ---
>  .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |  8 +--
>  .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    | 61 +++++++++++++++++-----
>  2 files changed, 51 insertions(+), 18 deletions(-)
> 
> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
> index 66e94dc..c2df4ce 100644
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
[...]
> @@ -512,21 +527,39 @@ qlcnic_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *p)
>  	if (!test_bit(__QLCNIC_DEV_UP, &adapter->state))
>  		return;
>  
> -	regs_buff[i++] = 0xFFEFCDAB; /* Marker btw regs and ring count*/
> -
> -	regs_buff[i++] = 1; /* No. of tx ring */
> -	regs_buff[i++] = le32_to_cpu(*(adapter->tx_ring->hw_consumer));
> -	regs_buff[i++] = readl(adapter->tx_ring->crb_cmd_producer);
> -
> -	regs_buff[i++] = 2; /* No. of rx ring */
> -	regs_buff[i++] = readl(recv_ctx->rds_rings[0].crb_rcv_producer);
> -	regs_buff[i++] = readl(recv_ctx->rds_rings[1].crb_rcv_producer);
> -
> -	regs_buff[i++] = adapter->max_sds_rings;
> +	/* Marker btw regs and TX ring count */
> +	regs_buff[i++] = QLCNIC_TX_RING_MARKER;
[...]

This is really sad; why don't you write a proper dump parser for ethtool
rather than including markers that make it slightly easier to read hex
dumps?

And when changing the dump format in an incompatible way like this, you
should also bump the version number.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
