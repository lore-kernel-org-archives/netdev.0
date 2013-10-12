From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8168-dkms and interaction with IOMMU setting
Date: Sat, 12 Oct 2013 11:50:07 +0200
Message-ID: <20131012095007.GA24174@electric-eye.fr.zoreil.com>
References: <5258CE5E.7080700@torfree.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>,
	netdev@vger.kernel.org
To: gary@extremeground.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:51365 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752612Ab3JLJuZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Oct 2013 05:50:25 -0400
Content-Disposition: inline
In-Reply-To: <5258CE5E.7080700@torfree.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gary Dale <garydale@torfree.net> :
> I'm running Jessie. I just replaced my mainboard and was having some
> problems.

(so 3.10-3 something kernel from the dmesg)

> 1) I was not getting the RTL8168 onboard NIC to work. It seemed to
> be able to receive but not transmit if I read this ifconfig output
> correctly:
> 
> eth0      Link encap:Ethernet  HWaddr 94:de:80:b1:57:17
>           UP BROADCAST MULTICAST  MTU:1500  Metric:1
>           RX packets:86 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:0 errors:0 dropped:34 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000
>           RX bytes:15027 (14.6 KiB)  TX bytes:0 (0.0 B)
>           Interrupt:72 Base address:0xa000

You read correctly.

Dropped Rx are more common. Dropped Tx means the driver has not even
been able to hand packets to the network chipset (it sucks).

> I was not getting a DHCP address for eth0. I tried to set it
> manually and add a route to the router, but I still couldn't get
> out. I've also tried the SID r8168-dkms driver and the slightly more
> recent one from RealTek but they didn't work either.
> 
> The lspci listing for it is: 04:00.0 Ethernet controller: Realtek
> Semiconductor Co., Ltd. RTL8111/8168/8411 PCI Express Gigabit
> Ethernet Controller (rev 06)

Your message does not include the XID line that the r8169 kernel
driver (*not* Realtek's own driver) displays to identify the chipset.
It could help.

[...]
> I'm also getting a lot of IO_PAGE_FAULT errors now that weren't
> there before. I've attached the dmesg log in case you need it. I
> don't know if this is of interest to you but it does seem to have an
> impact on the r8168 NIC.
[...]
> [    1.403202] r8168 Gigabit Ethernet driver 8.036.00-NAPI loaded
> [    1.403308] r8168 0000:04:00.0: irq 73 for MSI/MSI-X
> [    1.403509] xhci_hcd 0000:02:00.0: xHCI Host Controller
> [    1.403518] xhci_hcd 0000:02:00.0: new USB bus registered, assigned bus number 1
> [    1.403633] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[a few hundred of those removed]

You may be a (not-so) happy owner of a 8168f. If so you almost surely want
3ced8c955e74d319f3e3997f7169c79d524dfd06 ("r8169: enforce RX_MULTI_EN for
the 8168f.").

It's a post 3.11 kernel patch. You can either use a recent 3.12-rc kernel
or one of the 3.10.16, 3.11.5 stable kernels when they are released.

Your success / failure report will be welcome.

Thanks.

-- 
Ueimor
