From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH 05/14] [rndis_host] Fix rndis packet filter flags.
Date: Thu, 24 Jan 2008 16:55:20 -0800
Message-ID: <200801241655.20350.david-b@pacbell.net>
References: <20080120001410.25718.70147.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, bjd@jooz.net,
	netdev@vger.kernel.org
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp115.sbc.mail.sp1.yahoo.com ([69.147.64.88]:36395 "HELO
	smtp115.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754294AbYAYBUW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2008 20:20:22 -0500
In-Reply-To: <20080120001410.25718.70147.stgit@fate.lan>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 19 January 2008, Jussi Kivilinna wrote:
> RNDIS packet filter flags are not exactly the same as CDC flags
> so we cannot reuse them.
> 
> Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
> Signed-off-by: Bjorge Dijkstra <bjd@jooz.net>

Acked-by: David Brownell <dbrownell@users.sourceforge.net>


> ---
> 
>  drivers/net/usb/rndis_host.c |   23 ++++++++++++++++++++++-
>  1 files changed, 22 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
> index c686025..12daf9c 100644
> --- a/drivers/net/usb/rndis_host.c
> +++ b/drivers/net/usb/rndis_host.c
> @@ -256,6 +256,27 @@ struct rndis_keepalive_c {	/* IN (optionally OUT) */
>  #define OID_GEN_MAXIMUM_FRAME_SIZE	ccpu2(0x00010106)
>  #define OID_GEN_CURRENT_PACKET_FILTER	ccpu2(0x0001010e)
>  
> +/* packet filter bits used by OID_GEN_CURRENT_PACKET_FILTER */
> +#define RNDIS_PACKET_TYPE_DIRECTED		ccpu2(0x00000001)
> +#define RNDIS_PACKET_TYPE_MULTICAST		ccpu2(0x00000002)
> +#define RNDIS_PACKET_TYPE_ALL_MULTICAST		ccpu2(0x00000004)
> +#define RNDIS_PACKET_TYPE_BROADCAST		ccpu2(0x00000008)
> +#define RNDIS_PACKET_TYPE_SOURCE_ROUTING	ccpu2(0x00000010)
> +#define RNDIS_PACKET_TYPE_PROMISCUOUS		ccpu2(0x00000020)
> +#define RNDIS_PACKET_TYPE_SMT			ccpu2(0x00000040)
> +#define RNDIS_PACKET_TYPE_ALL_LOCAL		ccpu2(0x00000080)
> +#define RNDIS_PACKET_TYPE_GROUP			ccpu2(0x00001000)
> +#define RNDIS_PACKET_TYPE_ALL_FUNCTIONAL	ccpu2(0x00002000)
> +#define RNDIS_PACKET_TYPE_FUNCTIONAL		ccpu2(0x00004000)
> +#define RNDIS_PACKET_TYPE_MAC_FRAME		ccpu2(0x00008000)
> +
> +/* default filter used with RNDIS devices */
> +#define RNDIS_DEFAULT_FILTER ( \
> +	RNDIS_PACKET_TYPE_DIRECTED | \
> +	RNDIS_PACKET_TYPE_BROADCAST | \
> +	RNDIS_PACKET_TYPE_ALL_MULTICAST | \
> +	RNDIS_PACKET_TYPE_PROMISCUOUS)
> +
>  /*
>   * RNDIS notifications from device: command completion; "reverse"
>   * keepalives; etc
> @@ -551,7 +572,7 @@ static int rndis_bind(struct usbnet *dev, struct usb_interface *intf)
>  	u.set->oid = OID_GEN_CURRENT_PACKET_FILTER;
>  	u.set->len = ccpu2(4);
>  	u.set->offset = ccpu2((sizeof *u.set) - 8);
> -	*(__le32 *)(u.buf + sizeof *u.set) = ccpu2(DEFAULT_FILTER);
> +	*(__le32 *)(u.buf + sizeof *u.set) = RNDIS_DEFAULT_FILTER;
>  
>  	retval = rndis_command(dev, u.header);
>  	if (unlikely(retval < 0)) {
> 


