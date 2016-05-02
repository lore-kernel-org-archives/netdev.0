From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCHv2 bluetooth-next 08/10] ipv6: export ndisc functions
Date: Mon, 2 May 2016 21:39:08 +0200
Message-ID: <f5d5970d-afed-8a2f-9292-9ccb77f0e0db@stressinduktion.org>
References: <1461140382-4784-1-git-send-email-aar@pengutronix.de>
 <1461140382-4784-9-git-send-email-aar@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: kernel@pengutronix.de, marcel@holtmann.org,
	jukka.rissanen@linux.intel.com, stefan@osg.samsung.com,
	mcr@sandelman.ca, werner@almesberger.net,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	"David S . Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Alexander Aring <aar@pengutronix.de>, linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:56850 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754892AbcEBTjO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 15:39:14 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 5D947209D7
	for <netdev@vger.kernel.org>; Mon,  2 May 2016 15:39:13 -0400 (EDT)
In-Reply-To: <1461140382-4784-9-git-send-email-aar@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20.04.2016 10:19, Alexander Aring wrote:
> This patch exports some neighbour discovery functions which can be used
> by 6lowpan neighbour discovery ops functionality then.
> 
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> Cc: James Morris <jmorris@namei.org>
> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> Cc: Patrick McHardy <kaber@trash.net>
> Signed-off-by: Alexander Aring <aar@pengutronix.de>
> ---
>  include/net/ndisc.h | 16 ++++++++++++++++
>  net/ipv6/addrconf.c |  1 +
>  net/ipv6/ndisc.c    | 28 ++++++++++------------------
>  3 files changed, 27 insertions(+), 18 deletions(-)
> 
> diff --git a/include/net/ndisc.h b/include/net/ndisc.h
> index 14ed016..35a4396 100644
> --- a/include/net/ndisc.h
> +++ b/include/net/ndisc.h
> @@ -53,6 +53,15 @@ enum {
>  
>  #include <net/neighbour.h>
>  
> +/* Set to 3 to get tracing... */
> +#define ND_DEBUG 1
> +
> +#define ND_PRINTK(val, level, fmt, ...)				\
> +do {								\
> +	if (val <= ND_DEBUG)					\
> +		net_##level##_ratelimited(fmt, ##__VA_ARGS__);	\
> +} while (0)
> +

If the debug messages are well thought out, I think we could install
them always on debug level.

There are valid users now, so

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
