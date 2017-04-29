From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v4 net-next]smsc911x: Adding support for Micochip LAN9250
 Ethernet controller
Date: Sat, 29 Apr 2017 03:58:55 +0200
Message-ID: <20170429015855.GA32471@lunn.ch>
References: <C3C28FB10418274EB7FD7C2B85C796A441247C58@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        UNGLinuxDriver@microchip.com, steve.glendinning@shawell.net
To: David.Cai@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44960 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2992659AbdD2B7B (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Apr 2017 21:59:01 -0400
Content-Disposition: inline
In-Reply-To: <C3C28FB10418274EB7FD7C2B85C796A441247C58@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 28, 2017 at 10:28:32PM +0000, David.Cai@microchip.com wrote:
> From: David Cai <david.cai@microchip.com>
> 
> Adding support for Microchip LAN9250 Ethernet controller.
> 
> Signed-off-by: David Cai <david.cai@microchip.com>
> ---
> Changes
> V2
>  - email format changed
>  - remove unnecessary text in commit log Changes
> V3
>  - defined all supported Ethernet controller chip ID.
> V4
>  - changed 'if (pdata->generation == 4 && pdata->sub_generation)' to
>    'if ((pdata->idrev & 0xFFFF0000) == LAN9250)' for more readable
> 
>  drivers/net/ethernet/smsc/smsc911x.c | 55 ++++++++++++++++++++++++------------
>  drivers/net/ethernet/smsc/smsc911x.h | 19 +++++++++++++
>  2 files changed, 56 insertions(+), 18 deletions(-)
> 
> diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
> index fa5ca09..0cf956d 100644
> --- a/drivers/net/ethernet/smsc/smsc911x.c
> +++ b/drivers/net/ethernet/smsc/smsc911x.c
> @@ -25,7 +25,7 @@
>   *   LAN9215, LAN9216, LAN9217, LAN9218
>   *   LAN9210, LAN9211
>   *   LAN9220, LAN9221
> - *   LAN89218
> + *   LAN89218,LAN9250
>   *
>   */
>  
> @@ -104,6 +104,9 @@ struct smsc911x_data {
>  	/* used to decide which workarounds apply */
>  	unsigned int generation;
>  
> +	/* used to decide which sub generation product work arounds to apply */
> +	unsigned int sub_generation;

Isn't this now pointless? If it is not used anywhere, you should not
add it.

    Andrew
