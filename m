From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] METH: fix MAC address handling
Date: Sun, 06 Jan 2008 00:23:05 -0800 (PST)
Message-ID: <20080106.002305.99653155.davem@davemloft.net>
References: <20080105224842.78EDCC2EFB@solo.franken.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org,
	ralf@linux-mips.org, jgarzik@pobox.com
To: tsbogend@alpha.franken.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34087
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750728AbYAFIXG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jan 2008 03:23:06 -0500
In-Reply-To: <20080105224842.78EDCC2EFB@solo.franken.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Date: Sat,  5 Jan 2008 23:48:42 +0100 (CET)

> meth didn't set a valid mac address during probing, but later during
> open. Newer kernel refuse to open device with 00:00:00:00:00:00 as
> mac address -> dead ethernet. This patch sets the mac address in
> the probe function and uses only the mac address from the netdevice
> struct when setting up the hardware.
> 
> Signed-off-by: Thomas Bogendoerfer <tsbogend@alpha.franken.de>

Applied, thanks.

> +	u64 macaddr;
>  
> -	for (i = 0; i < 6; i++)
> -		dev->dev_addr[i] = o2meth_eaddr[i];
>  	DPRINTK("Loading MAC Address: %s\n", print_mac(mac, dev->dev_addr));
> -	mace->eth.mac_addr = (*(unsigned long*)o2meth_eaddr) >> 16;
> +	macaddr = 0;
> +	for (i = 0; i < 6; i++)
> +		macaddr |= dev->dev_addr[i] << ((5 - i) * 8);
> +
> +	mace->eth.mac_addr = macaddr;
>  }
>  
>  /*

Can you double-check that this conversion is equivalent.

I know that this whole driver is full of assumptions about
the endianness of the system this chip is found on, so
I'm only interested in if the transformation is equivalent
and the driver will keep working properly.

Thanks.
