From: Maciej Rutecki <maciej.rutecki@gmail.com>
Subject: Re: 2.6.37 regression: adding main interface to a bridge breaks vlan interface RX
Date: Sun, 23 Jan 2011 18:45:20 +0100
Message-ID: <201101231845.20505.maciej.rutecki@gmail.com>
References: <4D32FC1C.3010905@simon.arlott.org.uk>
Reply-To: maciej.rutecki@gmail.com
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	jesse@nicira.com
To: Simon Arlott <simon@fire.lp0.eu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D32FC1C.3010905@simon.arlott.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I created a Bugzilla entry at 
https://bugzilla.kernel.org/show_bug.cgi?id=27432
for your bug report, please add your address to the CC list in there, thanks!

On niedziela, 16 stycznia 2011 o 15:09:32 Simon Arlott wrote:
> [    1.666706] forcedeth 0000:00:08.0: ifname eth0, PHY OUI 0x5043 @ 16,
> addr 00:e0:81:4d:2b:ec [    1.666767] forcedeth 0000:00:08.0: highdma csum
> vlan pwrctl mgmt gbit lnktim msi desc-v3
> 
> I have eth0 and eth0.3840 which works until I add eth0 to a bridge.
> While eth0 is in a bridge (the bridge device is up), eth0.3840 is unable
> to receive packets. Using tcpdump on eth0 shows the packets being
> received with a VLAN tag but they don't appear on eth0.3840. They appear
> with the VLAN tag on the bridge interface.
> 
> If I remove eth0 from the bridge, eth0.3840 starts working again. It
> still works if eth0.3840 is part of a bridge but eth0 isn't (the device
> is in promiscuous mode). I've only tested with broadcast traffic.
> 
> This works with 2.6.36.
> 
> git bisect produces 3701e51382a026cba10c60b03efabe534fba4ca4 as the
> first bad commit.
> 
> The behaviour of drivers/net/forcedeth.c nv_rx_process_optimized looks
> ok - vlan_gro_receive and napi_gro_receive are called correctly. (The
> likely(!np->vlangrp) looks odd as it'll always be false if vlans are in
> use).

-- 
Maciej Rutecki
http://www.maciek.unixy.pl
