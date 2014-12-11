From: David Miller <davem@davemloft.net>
Subject: Re: randconfig build error with next-20141210, in
 drivers/net/ethernet/broadcom/genet
Date: Thu, 11 Dec 2014 14:22:20 -0500 (EST)
Message-ID: <20141211.142220.610076934853342634.davem@davemloft.net>
References: <CA+r1ZhjxtK8BtF16Mr9jXjqvFVV7KAAFjWqfVFUibNreZwZxTw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, f.fainelli@gmail.com,
	netdev@vger.kernel.org
To: jim.epost@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+r1ZhjxtK8BtF16Mr9jXjqvFVV7KAAFjWqfVFUibNreZwZxTw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jim Davis <jim.epost@gmail.com>
Date: Wed, 10 Dec 2014 09:10:45 -0700

> Building with the attached random configuration file,
> 
> ERROR: "fixed_phy_register"
> [drivers/net/ethernet/broadcom/genet/genet.ko] undefined!

Florian, I don't understand why FIXED_PHY is only selected in Kconfig
if the driver is statically built into the kernel.

That makes no sense at all, you should need that module regardless of
how the driver itself is enabled.

Can't we just remove the "XXX=y" in all of those silly:

	select FIXED_PHY if XXX=y

expressions?

There are three such cases right now:

drivers/net/dsa/Kconfig:	select FIXED_PHY if NET_DSA_BCM_SF2=y
drivers/net/ethernet/broadcom/Kconfig:	select FIXED_PHY if BCMGENET=y
drivers/net/ethernet/broadcom/Kconfig:	select FIXED_PHY if SYSTEMPORT=y
