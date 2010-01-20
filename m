From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH net-next-2.6 02/13] net-caif: add CAIF header files
Date: Wed, 20 Jan 2010 15:27:39 -0800
Message-ID: <20100120152739.31aacc08.randy.dunlap@oracle.com>
References: <1264028130-14364-1-git-send-email-sjur.brandeland@stericsson.com>
	<1264028130-14364-3-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, marcel@holtmann.org,
	stefano.babic@babic.homelinux.org
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:39764 "EHLO
	rcsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751101Ab0ATX23 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2010 18:28:29 -0500
In-Reply-To: <1264028130-14364-3-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Jan 2010 23:55:19 +0100 sjur.brandeland@stericsson.com wrote:

Hi,

Just a couple of nits here (below):


> From: Sjur Braendeland <sjur.brandeland@stericsson.com>
> 
> Add CAIF types for Socket Address, Socket Options,
> and configuration parameters for the GPRS IP network interface.
> 
> Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
> ---
>  include/linux/caif/caif_config.h |  155 ++++++++++++++++++++++++++++++++++++
>  include/linux/caif/caif_socket.h |  161 ++++++++++++++++++++++++++++++++++++++
>  include/linux/caif/if_caif.h     |   71 +++++++++++++++++
>  3 files changed, 387 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/caif/caif_config.h b/include/linux/caif/caif_config.h
> new file mode 100644
> index 0000000..5de8bd2
> --- /dev/null
> +++ b/include/linux/caif/caif_config.h
> @@ -0,0 +1,155 @@
> +/*
> + * CAIF Channel Configuration definitions.
> + * Copyright (C) ST-Ericsson AB 2010
> + * Author:	Sjur Brendeland/ sjur.brandeland@stericsson.com
> + * License terms: GNU General Public License (GPL) version 2
> + */
> +
> +#ifndef CAIF_CONFIG_H_
> +#define CAIF_CONFIG_H_
> +

...

> +struct caif_channel_config {
> +	char name[16];
> +	enum caif_channel_type type;
> +	unsigned priority;
> +	enum caif_phy_preference phy_pref;
> +	char phy_name[16];
> +
> +	/** Union of channel type-specific configuration parameters.

Don't use /** here.

> +	 * 'switched' by attribute type.
> +	 */
> +	union {
> +		/* CAIF_CHTYPE_DATAGRAM */
> +		struct {
> +			unsigned connection_id;
> +		} dgm;
> +		/* CAIF_CHTYPE_VIDEO */
> +		struct {
> +			unsigned connection_id;
> +		} video;
> +		/* CAIF_CHTYPE_RFM */
> +		struct {
> +			unsigned connection_id;
> +			char volume[20];
> +		} rfm;
> +		/* CAIF_CHTYPE_UTILITY */
> +		struct {
> +			unsigned fifosize_kb;
> +			unsigned fifosize_bufs;
> +			char name[16];
> +			unsigned char params[256];
> +			int paramlen;
> +		} utility;
> +
> +	} u;
> +};
> +
> +#endif				/* CAIF_CONFIG_H_ */

> diff --git a/include/linux/caif/if_caif.h b/include/linux/caif/if_caif.h
> new file mode 100644
> index 0000000..e1991b1
> --- /dev/null
> +++ b/include/linux/caif/if_caif.h
> @@ -0,0 +1,71 @@
> +/*
> + * Copyright (C) ST-Ericsson AB 2010
> + * Author:	Sjur Brendeland/ sjur.brandeland@stericsson.com
> + * License terms: GNU General Public License (GPL) version 2
> + */
> +
> +#ifndef IF_CAIF_H_
> +#define IF_CAIF_H_
> +#include <linux/sockios.h>
> +#include <linux/types.h>
> +#include <linux/socket.h>
> +
> +/**
> + * enum sioc_caif -	SOCKIO for creating new CAIF Net Devices.
> + * @SIOCCAIFNETNEW:	Used to create a new instance of the CAIF IP Interface.
> + *			struct ifreq containing struct ifcaif_param are used
> + *			as parameters. ifr_name must be filled in.
> + * @SIOCCAIFNETCHANGE:	As above, but changes a disconnected CAIF IP Inteface.
> + * @SIOCCAIFNETREMOVE:	Removes a CAIF IP Interface.
> + *
> + * CAIF IP Interface can be created, changed and deleted,
> + * by this enum. In addition standard Socket IO Controls (SIGIOC*)
> + * can be used to manage standard IP Interface parameters.
> + * The struct ifreq are used to carry parameters.
> + */
> +enum sioc_caif {
> +	SIOCCAIFNETNEW = SIOCPROTOPRIVATE,
> +	SIOCCAIFNETCHANGE,
> +	SIOCCAIFNETREMOVE
> +};
> +
> +
> +/**
> + * struct ifcaif_param - Parameters for creating CAIF Network Interface.
> + *
> + * When using SIOCCAIFNETNEW to create a CAIF IP interface, this structure
> + * is used for configuration data.
> + * The attribute ifr_ifru.ifru_data in struct struct ifreq must be set
> + * point at an instance of struct ifcaif_param.
> + *
> + * @ipv4_connid:  Connection ID for IPv4 PDP Context.
> + * @ipv6_connid:  Connection ID for IPv6 PDP Context.
> + * @loop:	  If different from zero, device is doing loopback
> + */
> +struct ifcaif_param {
> +	__u32			ipv4_connid;
> +	__u32			ipv6_connid;
> +	__u8			loop;
> +};
> +
> +/**
> + * enum ifla_caif

Above line needs " - <short description>" on it.

> + * When using RT Netlink to create, destroy or configure a CAIF IP interface,
> + * enum ifla_caif is used to specify the configuration attributes.
> + *
> + * @IFLA_CAIF_IPV4_CONNID:  Connection ID for IPv4 PDP Context.
> + *			    The type of attribute is NLA_U32.
> + * @IFLA_CAIF_IPV6_CONNID:  Connection ID for IPv6 PDP Context.
> + *			    The type of attribute is NLA_U32.
> + * @IFLA_CAIF_LOOPBACK:	    If different from zero, device is doing loopback
> + *			    The type of attribute is NLA_U8.
> + */
> +enum ifla_caif {
> +	IFLA_CAIF_IPV4_CONNID,
> +	IFLA_CAIF_IPV6_CONNID,
> +	IFLA_CAIF_LOOPBACK,
> +	__IFLA_CAIF_MAX
> +};
> +#define	IFLA_CAIF_MAX (__IFLA_CAIF_MAX-1)
> +
> +#endif /*IF_CAIF_H_*/
> -- 


---
~Randy
