From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 4/7] net: emaclite: Add support for little-endian
 platforms
Date: Wed, 29 Sep 2010 15:11:46 +0900
Message-ID: <20100929061146.GA2439@angua.secretlab.ca>
References: <1285739538-29058-1-git-send-email-monstr@monstr.eu>
 <1285739538-29058-2-git-send-email-monstr@monstr.eu>
 <1285739538-29058-3-git-send-email-monstr@monstr.eu>
 <1285739538-29058-4-git-send-email-monstr@monstr.eu>
 <1285739538-29058-5-git-send-email-monstr@monstr.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, john.williams@petalogix.com,
	edgar.iglesias@gmail.com, duyl@xilinx.com, linnj@xilinx.com,
	microblaze-uclinux@itee.uq.edu.au,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org
To: Michal Simek <monstr@monstr.eu>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1285739538-29058-5-git-send-email-monstr@monstr.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 29, 2010 at 03:52:15PM +1000, Michal Simek wrote:
> Upcomming Microblaze is little endian that's why is necessary
> to fix protocol and length loading.
> 
> Signed-off-by: Michal Simek <monstr@monstr.eu>
> CC: "David S. Miller" <davem@davemloft.net>
> CC: Grant Likely <grant.likely@secretlab.ca>
> CC: Eric Dumazet <eric.dumazet@gmail.com>
> CC: netdev@vger.kernel.org
> CC: linux-kernel@vger.kernel.org
> CC: devicetree-discuss@lists.ozlabs.org

This should go via davem, but it looks correct to me.

Acked-by: Grant Likely <grant.likely@secretlab.ca>

> ---
>  drivers/net/xilinx_emaclite.c |    8 ++++----
>  1 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/xilinx_emaclite.c b/drivers/net/xilinx_emaclite.c
> index 71122ee..533ebb1 100644
> --- a/drivers/net/xilinx_emaclite.c
> +++ b/drivers/net/xilinx_emaclite.c
> @@ -430,8 +430,8 @@ static u16 xemaclite_recv_data(struct net_local *drvdata, u8 *data)
>  	}
>  
>  	/* Get the protocol type of the ethernet frame that arrived */
> -	proto_type = ((in_be32(addr + XEL_HEADER_OFFSET +
> -			XEL_RXBUFF_OFFSET) >> XEL_HEADER_SHIFT) &
> +	proto_type = ((ntohl(in_be32(addr + XEL_HEADER_OFFSET +
> +			XEL_RXBUFF_OFFSET)) >> XEL_HEADER_SHIFT) &
>  			XEL_RPLR_LENGTH_MASK);
>  
>  	/* Check if received ethernet frame is a raw ethernet frame
> @@ -439,9 +439,9 @@ static u16 xemaclite_recv_data(struct net_local *drvdata, u8 *data)
>  	if (proto_type > (ETH_FRAME_LEN + ETH_FCS_LEN)) {
>  
>  		if (proto_type == ETH_P_IP) {
> -			length = ((in_be32(addr +
> +			length = ((ntohl(in_be32(addr +
>  					XEL_HEADER_IP_LENGTH_OFFSET +
> -					XEL_RXBUFF_OFFSET) >>
> +					XEL_RXBUFF_OFFSET)) >>
>  					XEL_HEADER_SHIFT) &
>  					XEL_RPLR_LENGTH_MASK);
>  			length += ETH_HLEN + ETH_FCS_LEN;
> -- 
> 1.5.5.1
> 
