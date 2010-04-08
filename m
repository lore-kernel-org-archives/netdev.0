From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/1] add ethtool loopback support
Date: Thu, 08 Apr 2010 19:29:33 +0100
Message-ID: <1270751373.5055.22.camel@achroite.uk.solarflarecom.com>
References: <pvmbpdtn8yh.fsf@chavey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, therbert@google.com
To: chavey@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:50587 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758895Ab0DHS3g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 14:29:36 -0400
In-Reply-To: <pvmbpdtn8yh.fsf@chavey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-04-08 at 10:35 -0700, chavey@google.com wrote:
> From: Ranjit Manomohan <ranjitm@google.com>
> Date: Wed, 7 Apr 2010 15:19:48 -0700
> 
> Add an ethtool option to use internal loopback mode for testing. 
> This feature is used for component and driver test coverage by putting
> the device in hardware loopback mode and sending / receiving network
> traffic from a user application to test the hardware and driver
> transmit / receive paths. 
> 
> Signed-off-by: laurent chavey <chavey@google.com>
> ---
>  include/linux/ethtool.h |   16 ++++++++++++++++
>  net/core/ethtool.c      |   40 ++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 56 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index b33f316..df1dcc7 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -292,6 +292,18 @@ struct ethtool_stats {
>  	__u64	data[0];
>  };
>  
> +/* for setting the NIC into loopback mode */
> +struct ethtool_loopback {
> +	u32 cmd;		/* ETHTOOL_SLOOPBACK */
> +	u32 type;		/* ethtool_loopback_type */
> +};
> +
> +enum ethtool_loopback_type {
> +	ETH_MAC			= 0x00000001,
> +	ETH_PHY_INT		= 0x00000002,
> +	ETH_PHY_EXT		= 0x00000004
> +};
[...]

There are many different places you can loop back within a MAC or PHY,
not to mention bypassing the MAC altogether.  See
drivers/net/sfc/mcdi_pcol.h, starting from the line
'#define MC_CMD_LOOPBACK_NONE 0'.  I believe we implement all of those
loopback modes on at least one board.

Also are these supposed to be an enumeration or flags?  In theory you
could use wire-side and host-side loopback at the same time if they
don't overlap, but it's probably too much trouble to bother with.  Any
other combination is meaningless.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

