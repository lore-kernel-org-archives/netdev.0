From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [PATCH net 1/2] tg3: Fix for diasllow rx coalescing time to be 0
Date: Wed, 3 Aug 2016 09:04:44 -0700
Message-ID: <7d591d9f-463b-cedd-5590-c4ff8260ffa0@hpe.com>
References: <1470197640-13587-1-git-send-email-siva.kallam@broadcom.com>
 <1470197640-13587-2-git-send-email-siva.kallam@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, michael.chan@broadcom.com,
	prashant@broadcom.com, satish.baddipadige@broadcom.com
To: skallam <siva.kallam@broadcom.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t2353.austin.hpe.com ([15.233.44.26]:36180 "EHLO
	g2t2353.austin.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752810AbcHCQGI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2016 12:06:08 -0400
In-Reply-To: <1470197640-13587-2-git-send-email-siva.kallam@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/02/2016 09:13 PM, skallam wrote:
> From: Satish Baddipadige <satish.baddipadige@broadcom.com>
>
> When the rx coalescing time is 0, interrupts
> are not generated from the controller and rx path hangs.
> To avoid this rx hang, updating the driver to not allow
> rx coalescing time to be 0.
>
> Signed-off-by: Satish Baddipadige <satish.baddipadige@broadcom.com>
> Signed-off-by: Siva Reddy Kallam <siva.kallam@broadcom.com>
> Signed-off-by: Michael Chan <michael.chan@broadcom.com>
> ---
>  drivers/net/ethernet/broadcom/tg3.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> index ff300f7..f3c6c91 100644
> --- a/drivers/net/ethernet/broadcom/tg3.c
> +++ b/drivers/net/ethernet/broadcom/tg3.c
> @@ -14014,6 +14014,7 @@ static int tg3_set_coalesce(struct net_device *dev, struct ethtool_coalesce *ec)
>  	}
>
>  	if ((ec->rx_coalesce_usecs > MAX_RXCOL_TICKS) ||
> +	    (!ec->rx_coalesce_usecs) ||
>  	    (ec->tx_coalesce_usecs > MAX_TXCOL_TICKS) ||
>  	    (ec->rx_max_coalesced_frames > MAX_RXMAX_FRAMES) ||
>  	    (ec->tx_max_coalesced_frames > MAX_TXMAX_FRAMES) ||
>

Should anything then happen with:

         /* No rx interrupts will be generated if both are zero */
         if ((ec->rx_coalesce_usecs == 0) &&
             (ec->rx_max_coalesced_frames == 0))
                 return -EINVAL;


which is the next block of code?  The logic there seems to suggest that 
it was intended to be able to have an rx_coalesce_usecs of 0 and rely on 
packet arrival to trigger an interrupt.  Presumably setting 
rx_max_coalesced_frames to 1 to disable interrupt coalescing.

happy benchmarking,

rick jones
