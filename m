From: Ben Dooks <ben-linux@fluff.org>
Subject: Re: [PATCH 1/2] [DM9000] Added support for big-endian hosts
Date: Thu, 16 Aug 2007 18:00:25 +0100
Message-ID: <20070816170025.GC12547@fluff.org.uk>
References: <200708161015.35337.laurentp@cse-semaphore.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ben Dooks <ben-linux@fluff.org>
To: Laurent Pinchart <laurentp@cse-semaphore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:63243 "EHLO
	aeryn.fluff.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752491AbXHPRA3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2007 13:00:29 -0400
Content-Disposition: inline
In-Reply-To: <200708161015.35337.laurentp@cse-semaphore.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 16, 2007 at 10:15:35AM +0200, Laurent Pinchart wrote:
> This patch splits the receive status in 8bit wide fields and convert the
> packet length from little endian to CPU byte order.
> 
> Signed-off-by: Laurent Pinchart <laurentp@cse-semaphore.com>
Acked-by: Ben Dooks <ben-linux@fluff.org>
> ---
>  drivers/net/dm9000.c |   13 +++++++------
>  1 files changed, 7 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
> index c3de81b..a424810 100644
> --- a/drivers/net/dm9000.c
> +++ b/drivers/net/dm9000.c
> @@ -894,7 +894,8 @@ dm9000_timer(unsigned long data)
>  }
>  
>  struct dm9000_rxhdr {
> -	u16	RxStatus;
> +	u8	RxPktReady;
> +	u8	RxStatus;
>  	u16	RxLen;
>  } __attribute__((__packed__));
>  
> @@ -935,7 +936,7 @@ dm9000_rx(struct net_device *dev)
>  
>  		(db->inblk)(db->io_data, &rxhdr, sizeof(rxhdr));
>  
> -		RxLen = rxhdr.RxLen;
> +		RxLen = le16_to_cpu(rxhdr.RxLen);
>  
>  		/* Packet Status check */
>  		if (RxLen < 0x40) {
> @@ -947,17 +948,17 @@ dm9000_rx(struct net_device *dev)
>  			PRINTK1("RST: RX Len:%x\n", RxLen);
>  		}
>  
> -		if (rxhdr.RxStatus & 0xbf00) {
> +		if (rxhdr.RxStatus & 0xbf) {
>  			GoodPacket = false;
> -			if (rxhdr.RxStatus & 0x100) {
> +			if (rxhdr.RxStatus & 0x01) {
>  				PRINTK1("fifo error\n");
>  				db->stats.rx_fifo_errors++;
>  			}
> -			if (rxhdr.RxStatus & 0x200) {
> +			if (rxhdr.RxStatus & 0x02) {
>  				PRINTK1("crc error\n");
>  				db->stats.rx_crc_errors++;
>  			}
> -			if (rxhdr.RxStatus & 0x8000) {
> +			if (rxhdr.RxStatus & 0x80) {
>  				PRINTK1("length error\n");
>  				db->stats.rx_length_errors++;
>  			}
> -- 
> 1.5.0
> 
> -- 
> Laurent Pinchart
> CSE Semaphore Belgium
> 
> Chauss?e de Bruxelles, 732A
> B-1410 Waterloo
> Belgium
> 
> T +32 (2) 387 42 59
> F +32 (2) 387 42 75
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
