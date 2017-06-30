From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 1/6] net: add new netdevice feature for tunnel
 offloading
Date: Fri, 30 Jun 2017 17:50:01 +0200
Message-ID: <20170630175001.1969a85a@griffin>
References: <cover.1498743778.git.sd@queasysnail.net>
        <79e58d61b15ff497524cde07c00c2165cf033ef2.1498743778.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40632 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751865AbdF3PuF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 30 Jun 2017 11:50:05 -0400
In-Reply-To: <79e58d61b15ff497524cde07c00c2165cf033ef2.1498743778.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 30 Jun 2017 15:19:45 +0200, Sabrina Dubroca wrote:
> This adds a new netdevice feature, so that tunnel offloading can be
> disabled by the administrator on some netdevices, using the
> "tunnel-offload" ethtool feature.
> 
> This feature is set for all devices that provide ndo_udp_tunnel_add.

This patchset looks great, Sabrina! A few comments below.

> --- a/include/linux/netdev_features.h
> +++ b/include/linux/netdev_features.h
> @@ -76,6 +76,7 @@ enum {
>  	NETIF_F_HW_TC_BIT,		/* Offload TC infrastructure */
>  	NETIF_F_HW_ESP_BIT,		/* Hardware ESP transformation offload */
>  	NETIF_F_HW_ESP_TX_CSUM_BIT,	/* ESP with TX checksum offload */
> +	NETIF_F_TUNNEL_OFFLOAD_BIT,     /* Tunnel offloads */

"Tunnel offload" is very broad. Could we be more specific, e.g. "RSS
tunnel offload" or such? NETIF_F_HW_TUNNEL_RSS?

> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -106,6 +106,7 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
>  	[NETIF_F_HW_TC_BIT] =		 "hw-tc-offload",
>  	[NETIF_F_HW_ESP_BIT] =		 "esp-hw-offload",
>  	[NETIF_F_HW_ESP_TX_CSUM_BIT] =	 "esp-tx-csum-hw-offload",
> +	[NETIF_F_TUNNEL_OFFLOAD_BIT] =	 "tunnel-offload",
>  };

And here, too. "rss-tunnel-offload"?

Thanks!

 Jiri
