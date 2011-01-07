From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: 2.6.37 vlans on bnx2 not functional, panic with tcpdump
Date: Fri, 7 Jan 2011 09:50:53 -0800
Message-ID: <1294422653.14051.11.camel@HP1>
References: <4D2634DE.2060907@gmail.com> <1294357941.21580.2.camel@HP1>
 <1294361206.21580.7.camel@HP1>
 <AANLkTi=PGPVRbS3XViskpZ0GSS8ouBcgVZYYG9EoM-Nz@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: selsinork <selsinork@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTi=PGPVRbS3XViskpZ0GSS8ouBcgVZYYG9EoM-Nz@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Fri, 2011-01-07 at 00:57 -0800, selsinork wrote:
> On Fri, Jan 7, 2011 at 12:46 AM, Michael Chan <mchan@broadcom.com>
> wrote:
>         
>         
>         May be you have management firmware running on your devices
>         that can
>         change the behavior.  Can you provide ethtool -i eth0 on both
>         bnx2
>         devices on your system?
> 
> This particular system has four onboard ports, a two port add-in card
> and a single port fiber card all using bnx2, so I have some options to
> try different devices if there's something different about them.
> Details of all of them below.
> 
> Booting the same system back to 2.6.36 with the patch I mentioned
> previously leaves me with a functioning network, so given it could be
> management firmware related, why does it work on .36 but not .37 ?  

Management firmware affects the stripping/unstripping of VLAN tags.  If
management firmware is enabled, we need to configure the chip to always
strip the VLAN tag, otherwise management firmware will not receive the
packets properly.

The kernel has undergone major VLAN changes at this time, so there may
be a problem depending on what stripping mode we're in.  The tg3 driver
is having some similar problems that haven't been completely resolved
yet.

Anyway, I'll wait for you to narrow this down further.  I'll also try to
do some additional testing myself.

You have management firmware (NCSI) enabled on eth0 and eth1, but not
the other devices (the firmware shown is NVRAM firmware).  If it's still
a problem, please see if there's a difference in behavior between the
devices with NCSI enabled and disabled.

Thanks.

>  The install is very stripped down, there's no udev or /sbin/hotplug
> loading firmware behind my back as neither are installed. So firmware
> is whatever comes with the kernel. Just having had a look, I see the
> firmware provided with the kernel has changed in .37, but the output
> of ethtool -i shows the same firmware being used with .36 and .37
> 
> Iain
> 
> 02:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5709
> Gigabit Ethernet (rev 20)
> 02:00.1 Ethernet controller: Broadcom Corporation NetXtreme II BCM5709
> Gigabit Ethernet (rev 20)
> 03:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5709
> Gigabit Ethernet (rev 20)
> 03:00.1 Ethernet controller: Broadcom Corporation NetXtreme II BCM5709
> Gigabit Ethernet (rev 20)
> 04:00.0 RAID bus controller: Hewlett-Packard Company Smart Array G6
> controllers (rev 01)
> 07:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5709
> Gigabit Ethernet (rev 20)
> 07:00.1 Ethernet controller: Broadcom Corporation NetXtreme II BCM5709
> Gigabit Ethernet (rev 20)
> 0a:00.0 PCI bridge: Broadcom EPB PCI-Express to PCI-X Bridge (rev c3)
> 0b:00.0 Ethernet controller: Broadcom Corporation NetXtreme II
> BCM5708S Gigabit Ethernet (rev 12)
> 
> from 2.6.37:
> 
> root@64bit:~# ethtool -i eth0
> driver: bnx2
> version: 2.0.17
> firmware-version: bc 5.2.2 NCSI 2.0.6
> bus-info: 0000:02:00.0
> root@64bit:~# ethtool -i eth1
> driver: bnx2
> version: 2.0.17
> firmware-version: bc 5.2.2 NCSI 2.0.6
> bus-info: 0000:02:00.1
> root@64bit:~# ethtool -i eth2
> driver: bnx2
> version: 2.0.17
> firmware-version: bc 5.2.2
> bus-info: 0000:03:00.0
> root@64bit:~# ethtool -i eth3
> driver: bnx2
> version: 2.0.17
> firmware-version: bc 5.2.2
> bus-info: 0000:03:00.1
> root@64bit:~# ethtool -i eth4
> driver: bnx2
> version: 2.0.17
> firmware-version: bc 5.2.2
> bus-info: 0000:07:00.0
> root@64bit:~# ethtool -i eth5
> driver: bnx2
> version: 2.0.17
> firmware-version: bc 5.2.2
> bus-info: 0000:07:00.1
> root@64bit:~# ethtool -i eth6
> driver: bnx2
> version: 2.0.17
> firmware-version: bc 1.9.6
> bus-info: 0000:0b:00.0
>  
> from 2.6.36:
> 
>  ethtool -i eth1
> driver: bnx2
> version: 2.0.17
> firmware-version: bc 5.2.2 NCSI 2.0.6
> bus-info: 0000:02:00.1
> 
