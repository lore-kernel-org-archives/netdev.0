From: Alexander Aring <aar@pengutronix.de>
Subject: Re: [PATCH bluetooth-next 07/10] ipv6: introduce neighbour discovery
 ops
Date: Mon, 18 Apr 2016 15:28:02 +0200
Message-ID: <5714E0E2.7040004@pengutronix.de>
References: <1460977108-4675-1-git-send-email-aar@pengutronix.de>
 <1460977108-4675-8-git-send-email-aar@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Cc: kernel@pengutronix.de, marcel@holtmann.org,
	jukka.rissanen@linux.intel.com, hannes@stressinduktion.org,
	stefan@osg.samsung.com, mcr@sandelman.ca, werner@almesberger.net,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	"David S . Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:44335 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751920AbcDRN2P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 09:28:15 -0400
In-Reply-To: <1460977108-4675-8-git-send-email-aar@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Am 04/18/2016 um 12:58 PM schrieb Alexander Aring:
> This patch introduces neighbour discovery ops callback structure. The
> structure contains at first receive and transmit handling for NS/NA and
> userspace option field functionality.
>
> These callback offers 6lowpan different handling, such as 802.15.4 short
> address handling or RFC6775 (Neighbor Discovery Optimization for IPv6 over
> 6LoWPANs).
>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> Cc: James Morris <jmorris@namei.org>
> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> Cc: Patrick McHardy <kaber@trash.net>
> Signed-off-by: Alexander Aring <aar@pengutronix.de>
> ---
>  include/linux/netdevice.h |  3 ++
>  include/net/ndisc.h       | 73 ++++++++++++++++++++++++++++++++++++++++++-----
>  net/ipv6/addrconf.c       |  1 +
>  net/ipv6/ndisc.c          | 71 +++++++++++++++++++++++++++++++--------------
>  net/ipv6/route.c          |  2 +-
>  5 files changed, 121 insertions(+), 29 deletions(-)
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 0052c42..4f1b3f2 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1677,6 +1677,9 @@ struct net_device {
>  #ifdef CONFIG_NET_L3_MASTER_DEV
>  	const struct l3mdev_ops	*l3mdev_ops;
>  #endif
> +#ifdef CONFIG_IPV6
> +	const struct ndisc_ops *ndisc_ops;
> +#endif

Need to change it to:

#if IS_ENABLED(CONFIG_IPV6)

as well also on other configs which can be builded as tristate.
Sorry for the noise, I will fix that in v2. :-)

- Alex
