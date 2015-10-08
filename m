From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH RFC] net: mvneta: add ethtool statistics
Date: Thu, 8 Oct 2015 09:51:41 +0100
Message-ID: <20151008085141.GA32532@n2100.arm.linux.org.uk>
References: <20151006165208.GE3557@lunn.ch>
 <E1ZjZ2q-00087d-Im@rmk-PC.arm.linux.org.uk>
 <20151007230333.GL17952@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:47324 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753932AbbJHIvs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 04:51:48 -0400
Content-Disposition: inline
In-Reply-To: <20151007230333.GL17952@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 08, 2015 at 01:03:33AM +0200, Andrew Lunn wrote:
> On Tue, Oct 06, 2015 at 09:41:08PM +0100, Russell King wrote:
> > Add support for the ethtool statistic interface, returning the full set
> > of statistics which both Armada 370 and Armada XP can support.
> > 
> > Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
> > ---
> > Andrew,
> > 
> > Here's the patch updated to use the example set by mv643xx_eth.c.
> 
> Hi Russell
> 
> I did some quick tests on an Armada XP based DLINK WRT1900AC. We have
> some inconsistencies:
> 
> root@wrt1900ac:~# ethtool -S eth0
> NIC statistics:
>      good_octets_received: 4300691
>      good_frames_received: 7655
...
>      good_octets_sent: 383562
>      good_frames_sent: 7665
>      excessive_collision: 0
>      multicast_frames_sent: 8
>      broadcast_frames_sent: 3
>      fc_sent: 0
>      internal_mac_transmit_err: 0
> root@wrt1900ac:~# ifconfig eth0
> eth0      Link encap:Ethernet  HWaddr 94:10:3e:80:bc:f3  
>           inet6 addr: fe80::9610:3eff:fe80:bcf3/64 Scope:Link
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:2 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:532 
>           RX bytes:497 (497.0 B)  TX bytes:648 (648.0 B)
>           Interrupt:27
> 
> I'm guessing ethtool is including the uboot TFTP packets, where as
> ifconfig is just Linux?

Yes, since the counters will be zero at reset.

> This would suggest the driver is not clearing the statistics when it
> loads. Should it?

That's an interesting question, one which I have no answer for.

> Apart from that, i pinged with a few different sizes and the right
> frame size counter went up. I broadcast pinged and the broadcast
> counter went up. So not exhaustive testing, but better than nothing.
> Since clearing the statistics is a separate issue:
> 
> Tested-by: Andrew Lunn <andrew@lunn.ch>

Thanks.

-- 
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
