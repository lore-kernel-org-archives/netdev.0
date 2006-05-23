From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: r8169 cardbus device naming weirdness
Date: Tue, 23 May 2006 10:51:08 -0700
Message-ID: <20060523105108.7c0e2367@localhost.localdomain>
References: <20060523174402.GG29687@bork.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:55529 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751144AbWEWRvT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 May 2006 13:51:19 -0400
To: Martin Hicks <mort@bork.org>
In-Reply-To: <20060523174402.GG29687@bork.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 23 May 2006 13:44:02 -0400
Martin Hicks <mort@bork.org> wrote:

> 
> Hi,
> 
> I've got a D-Link DGE-660TD that the driver claims to register as eth1,
> but it actually ends up being eth2.  (eth0 is the on-board NIC).
> 
> mort@socrates:~$ dmesg
> 
> [...]
> 
> r8169 Gigabit Ethernet driver 2.2LK-NAPI loaded
> ACPI: PCI Interrupt 0000:07:00.0[A] -> Link [LNKB] -> GSI 5 (level, low) -> IRQ 5
> eth1: Identified chip type is 'RTL8169s/8110s'.
> eth1: RTL8169 at 0xe8a36000, 00:13:46:29:65:62, IRQ 5
> mort@socrates:~$ sudo /sbin/ifconfig eth1 192.168.1.102 netmask 255.255.255.0
> SIOCSIFADDR: No such device
> eth1: ERROR while getting interface flags: No such device
> SIOCSIFNETMASK: No such device
> mort@socrates:~$ sudo /sbin/ifconfig eth2 192.168.1.102 netmask 255.255.255.0
> mort@socrates:~$ sudo /usr/sbin/ethtool -i eth2
> driver: r8169
> version: 2.2LK-NAPI
> firmware-version: 
> bus-info: 0000:07:00.0
> mort@socrates:~$ sudo /usr/sbin/ethtool -i eth1 
> Cannot get driver information: No such device
> mort@socrates:~$ 
> 
> 
> On a IBM T23 laptop running 2.6.16.14.

Most likely some user space script is renaming it.
Each distro seems to have it's own way of doing configuration, and most
do something in response to the hotplug event from device registration.
So it was eth1 until what ever ran in response to the hotplug event
decide to change it.
