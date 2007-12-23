From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH 5/8] Fix rndis packet filter flags.
Date: Sat, 22 Dec 2007 17:06:46 -0800
Message-ID: <20071223010646.83BC3230E0A@adsl-69-226-248-13.dsl.pltn13.pacbell.net>
References: <11983602942818-git-send-email-bjd@jooz.net>
 <1198360295996-git-send-email-bjd@jooz.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	jussi.kivilinna@mbnet.fi
To: bjd@jooz.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp119.sbc.mail.sp1.yahoo.com ([69.147.64.92]:30786 "HELO
	smtp119.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754026AbXLWBGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Dec 2007 20:06:48 -0500
In-Reply-To: <1198360295996-git-send-email-bjd@jooz.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From bjd@jooz.net  Sat Dec 22 13:53:12 2007
> From: Bjorge Dijkstra <bjd@jooz.net>
> To: dbrownell@users.sourceforge.net
> Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
> 	Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
> Subject: [PATCH 5/8] Fix rndis packet filter flags.
> Date: Sat, 22 Dec 2007 22:51:31 +0100
>
> From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
>
> RNDIS packet filter flags are not exactly the same as CDC flags
> so we cannot reuse them.
>
> Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
> Signed-off-by: Bjorge Dijkstra <bjd@jooz.net>

Acked-by: David Brownell <dbrownell@users.sourceforge.net>

Hmm, the list seems to have grown since I last looked at it.
Or maybe it's just that the MSFT documentation was so hard
to make sense of ... I never could figure out what the RNDIS
power management messages were supposed to be doing, or what
the extra seemingly-undocumented messages were there for.


> ---
>  drivers/net/usb/rndis_host.c |   23 ++++++++++++++++++++++-
>  1 files changed, 22 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
> index c686025..3c116f9 100644
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
> +	RNDIS_PACKET_TYPE_PROMISCUOUS )
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
> -- 
> 1.5.2.5
>
