From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: net: generic netdev_ioaddr
Date: Fri, 29 Oct 2004 23:13:24 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <m3u0sdb53f.fsf@defiant.pm.waw.pl>
References: <1099044244.9566.0.camel@localhost>
	<20041029131607.GU24336@parcelfarce.linux.theplanet.co.uk>
	<courier.418290EC.00002E85@courier.cs.helsinki.fi>
	<m3y8hpbaf9.fsf@defiant.pm.waw.pl>
	<20041029193827.GV24336@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pekka J Enberg <penberg@cs.helsinki.fi>, davem@davemloft.net,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Al Viro <viro@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20041029193827.GV24336@parcelfarce.linux.theplanet.co.uk> (Al
 Viro's message of "Fri, 29 Oct 2004 20:38:27 +0100")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Al Viro <viro@parcelfarce.linux.theplanet.co.uk> writes:

> What uses ->base_addr from the data returned by SIOCGIFMAP?

ifconfig I think:

eth0      Link encap:Ethernet  HWaddr 00:50:BA:70:68:3E  
          inet addr:10.0.0.2  Bcast:10.0.0.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:2796430 errors:1 dropped:0 overruns:0 frame:0
          TX packets:4056563 errors:3 dropped:0 overruns:0 carrier:3
          collisions:0 txqueuelen:1000 
          RX bytes:285233613 (272.0 Mb)  TX bytes:1252627624 (1194.5 Mb)
          Interrupt:10 Base address:0x4000 

With this driver it happens to be MMIO address.

I understand presenting this value to users might have some value:
it can help determine the physical port/card for a given netdev.
But it should be something like a description text set by the driver
(ie. containing PCI bus/device, or even ISA address for ISA non-PnP
card, possibly with other information).

It seems while some devices use SIOCGIFMAP (ie. by setting the fields
in netdev struct), support for SIOCSIFMAP doesn't make sense for most
hardware.

Drivers using SIOCSIFMAP (selecting media only?):
arch/cris/arch-v10/drivers/ethernet.c:    dev->set_config = e100_set_config;
drivers/net/au1000_eth.c:     dev->set_config = &au1000_set_config;
drivers/net/sis900.c: net_dev->set_config = &sis900_set_config;
drivers/net/arm/etherh.c:     dev->set_config         = etherh_set_config;
drivers/net/pcmcia/3c589_cs.c:    dev->set_config = &el3_config;
drivers/net/pcmcia/fmvj18x_cs.c:    dev->set_config = &fjn_config;
drivers/net/pcmcia/nmclan_cs.c:    dev->set_config = &mace_config;
drivers/net/pcmcia/pcnet_cs.c:    dev->set_config = &set_config;
drivers/net/pcmcia/smc91c92_cs.c:    dev->set_config = &s9k_config;
drivers/net/pcmcia/xirc2ps_cs.c:    dev->set_config = &do_config;
drivers/net/wan/sdla.c:       dev->set_config         = sdla_set_config;
drivers/net/wireless/ray_cs.c:    dev->set_config = &ray_dev_config;

I think I would mark this stuff obsolete, and remove when the drivers
are updated (if they need an update at all, they may support
ethtool/mii-tool already).
-- 
Krzysztof Halasa
