From: Premkumar Jonnala <pjonnala@broadcom.com>
Subject: RE: [PATCH net-next 1/4] switchdev: add bridge attributes
Date: Fri, 25 Sep 2015 04:32:16 +0000
Message-ID: <77EF4405DD4BB54AACCE7DB593DF6A9A9F22C5@SJEXCHMB14.corp.ad.broadcom.com>
References: <1443128370-27353-1-git-send-email-sfeldma@gmail.com>
 <1443128370-27353-2-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "jiri@resnulli.us" <jiri@resnulli.us>,
	"siva.mannem.lnx@gmail.com" <siva.mannem.lnx@gmail.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"vivien.didelot@savoirfairelinux.com"
	<vivien.didelot@savoirfairelinux.com>
To: "sfeldma@gmail.com" <sfeldma@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:7062 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750730AbbIYEcR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 00:32:17 -0400
In-Reply-To: <1443128370-27353-2-git-send-email-sfeldma@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked-by: Premkumar Jonnala

> -----Original Message-----
> From: sfeldma@gmail.com [mailto:sfeldma@gmail.com]
> Sent: Friday, September 25, 2015 2:29 AM
> To: netdev@vger.kernel.org
> Cc: jiri@resnulli.us; siva.mannem.lnx@gmail.com; Premkumar Jonnala;
> stephen@networkplumber.org; roopa@cumulusnetworks.com;
> andrew@lunn.ch; f.fainelli@gmail.com; vivien.didelot@savoirfairelinux.com
> Subject: [PATCH net-next 1/4] switchdev: add bridge attributes
> 
> From: Scott Feldman <sfeldma@gmail.com>
> 
> Setting the stage to push bridge-level attributes down to port driver so
> hardware can be programmed accordingly.  Bridge-level attribute example is
> ageing_time.  This is a per-bridge attribute, not a per-bridge-port attr.
> 
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> ---
>  include/net/switchdev.h      |    5 +++++
>  include/uapi/linux/if_link.h |    2 +-
>  2 files changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/include/net/switchdev.h b/include/net/switchdev.h
> index 319baab..54b2faa 100644
> --- a/include/net/switchdev.h
> +++ b/include/net/switchdev.h
> @@ -28,6 +28,7 @@ enum switchdev_attr_id {
>  	SWITCHDEV_ATTR_PORT_PARENT_ID,
>  	SWITCHDEV_ATTR_PORT_STP_STATE,
>  	SWITCHDEV_ATTR_PORT_BRIDGE_FLAGS,
> +	SWITCHDEV_ATTR_BRIDGE,
>  };
> 
>  struct switchdev_attr {
> @@ -38,6 +39,10 @@ struct switchdev_attr {
>  		struct netdev_phys_item_id ppid;	/* PORT_PARENT_ID
> */
>  		u8 stp_state;				/* PORT_STP_STATE
> */
>  		unsigned long brport_flags;		/*
> PORT_BRIDGE_FLAGS */
> +		struct switchdev_attr_bridge {		/* BRIDGE */
> +			enum ifla_br attr;
> +			u32 val;
> +		} bridge;
>  	} u;
>  };
> 
> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
> index 3a5f263..8d0ef1c 100644
> --- a/include/uapi/linux/if_link.h
> +++ b/include/uapi/linux/if_link.h
> @@ -222,7 +222,7 @@ enum in6_addr_gen_mode {
> 
>  /* Bridge section */
> 
> -enum {
> +enum ifla_br {
>  	IFLA_BR_UNSPEC,
>  	IFLA_BR_FORWARD_DELAY,
>  	IFLA_BR_HELLO_TIME,
> --
> 1.7.10.4
