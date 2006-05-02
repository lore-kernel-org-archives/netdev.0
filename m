From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: VJ Channel API - driver level (PATCH)
Date: Tue, 2 May 2006 16:00:58 -0700
Message-ID: <20060502160058.7af02254@localhost.localdomain>
References: <4457E2FE.50505@neterion.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:43207 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965032AbWEBXBC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 May 2006 19:01:02 -0400
To: Alex Aizman <alex@neterion.com>
In-Reply-To: <4457E2FE.50505@neterion.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 02 May 2006 15:53:50 -0700
Alex Aizman <alex@neterion.com> wrote:

> Signed-off-by: Alex Aizman <alex@xxxxxxxxxx>
> 
> Hacked netdevice.h to support multiple channels.
> 
> --- netdevice-orig.h	2006-03-04 10:01:38.000000000 -0800
> +++ netdevice-channel.h	2006-03-09 10:17:11.419955200 -0800
> @@ -246,6 +246,147 @@
>  
>  extern int __init netdev_boot_setup(char *str);
>  
> +#ifdef CONFIG_NET_CHANNELS
> +/***************  NETDEVICE HW CHANNELS data structures *****************/
> +/**
> + * enum netdev_hwchannel_rx_flow_e - Hardware receive channel "flow" types.
> + * @HWCH_RX_FLOW_NONE: does not filter rx packets.
> + * @HWCH_RX_FLOW_MACADDR: filters based upon the rx mac address
> + * @HWCH_RX_FLOW_VLAN_ID: filters based upon the rx vlan id tag
> + * @HWCH_RX_FLOW_VLAN_QOS: fikters based upon the vlan qos field
> + * @HWCH_RX_FLOW_PORT: filters based upon the tcp or udp receive port number
> + * @HWCH_RX_FLOW_L4_HASH: filters based upon a hash of the tcp session id
> + * @HWCH_RX_FLOW_L4_SPDM: filters based upon a hash of the four-tuple of the
> + * following: source ip, source port, destination ip, destinaton port
> + *
> + * A rx is bound to a specific device.  When one of thsese enums is used, 
> + * traffic is filtered onto the queue of only the requested type.  By default
> + * we use HWCH_RX_FLOW_NONE as we usually want all traffic from this device.
> + **/
> +typedef enum netdev_hwchannel_rx_flow_e  {
> +	HWCH_RX_FLOW_NONE,
> +	HWCH_RX_FLOW_MACADDR,
> +	HWCH_RX_FLOW_VLAN_ID,
> +	HWCH_RX_FLOW_VLAN_QOS,
> +	HWCH_RX_FLOW_PORT,
> +	HWCH_RX_FLOW_L4_HASH,
> +	HWCH_RX_FLOW_L4_SPDM,
> +} netdev_hwchan_rx_flow_e;
> +

No, not a typedef.  also pls use shorter names.
