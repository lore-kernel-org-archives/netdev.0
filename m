From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: dsa: fix mv88e6xxx switches
Date: Sat, 23 Jan 2016 23:12:32 +0100
Message-ID: <20160123221232.GJ3880@lunn.ch>
References: <E1aMvmm-0006G3-8T@rmk-PC.arm.linux.org.uk>
 <20160123181526.GD3880@lunn.ch>
 <20160123190622.GA10826@n2100.arm.linux.org.uk>
 <20160123193705.GE3880@lunn.ch>
 <20160123194856.GB10826@n2100.arm.linux.org.uk>
 <20160123201647.GH3880@lunn.ch>
 <20160123204416.GC10826@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev@vger.kernel.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41385 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754735AbcAWWMi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jan 2016 17:12:38 -0500
Content-Disposition: inline
In-Reply-To: <20160123204416.GC10826@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This shows port 0 is on vlan 0, but it should default to vlan 1 when
> no vlans are configured.  The patch below should at least allow some
> diagnosis of what's being requested, and when.
> 
> diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
> index a43354ed0607..8a9cf67eb16d 100644
> --- a/drivers/net/dsa/mv88e6xxx.c
> +++ b/drivers/net/dsa/mv88e6xxx.c
> @@ -1511,6 +1511,9 @@ int mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port,
>  	u16 vid;
>  	int err = 0;
>  
> +	printk("%s: port %d vid %u-%u flags %x\n",
> +		__func__, port, vlan->vid_begin, vlan->vid_end, vlan->flags);
> +

Hi Russell

Never called.

So i guess we have a kernel configuration difference.

I don't have CONFIG_BRIDGE_VLAN_FILTERING.

But DSA should not rely on this option for correct operation.

  Andrew
