From: Ben Greear <greearb@candelatech.com>
Subject: Re: [EXPERIMENTAL PATCH] 2.4 tulip jumbo frames
Date: Tue, 09 Dec 2003 09:28:23 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FD60637.2080009@candelatech.com>
References: <20031209160632.D1345@sygehus.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Rask Ingemann Lambertsen <rask@sygehus.dk>
In-Reply-To: <20031209160632.D1345@sygehus.dk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Rask Ingemann Lambertsen wrote:
> Attached is a patch which enables jumbo frames on tulip based boards. It  
> makes it possible to set an MTU of up to 2025 bytes. However, testing
> against an NE3200 board using 10base-2 shows assorted problems when going
> above 2018 bytes (for frames without VLAN tags). The problems show up as
> framing errors, bad CRCs and such (in both directions).
> 
> The patch is against 2.4.22-bk45.

> +static int tulip_change_mtu (struct net_device *dev, int mtu)
> +{
> +	if (netif_running (dev))
> +		return (-EBUSY);
> +
> +	if (mtu < 0 || mtu > PKT_BUF_SZ_MAX - VLAN_ETH_HLEN - 4)
> +		return (-EINVAL);

I suppose you could let them ignore the VLAN_ETH_HLEN if you
really wanted to (in case they are not running VLANs).

But, this should work fine too.

--Ben

> +
> +	dev->mtu = mtu;
> +	return (0);
> +}
> +

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
