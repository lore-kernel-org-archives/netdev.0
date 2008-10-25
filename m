From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: r8169 MAC addresses broken
Date: Sat, 25 Oct 2008 23:49:46 +0200
Message-ID: <4903947A.3060206@gmail.com>
References: <490380C8.6070003@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Simon Arlott <simon@fire.lp0.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:43736 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751277AbYJYVtv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Oct 2008 17:49:51 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1399685fgg.17
        for <netdev@vger.kernel.org>; Sat, 25 Oct 2008 14:49:49 -0700 (PDT)
In-Reply-To: <490380C8.6070003@simon.arlott.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/25/2008 10:25 PM, Simon Arlott wrote:
> Somewhere between 2.6.24 (it would take too long to bisect) and now 
> (e013e13bf605b9e6b702adffbe2853cfc60e7806), 2/3 of my MAC addresses 
> are getting set to zero:
> 
> [    1.533565] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
> [    1.539277] r8169 0000:00:09.0: PCI INT A -> Link[LNKC] -> GSI 10 (level, low) -> IRQ 10
> [    1.547518] r8169 0000:00:09.0: PCI: Disallowing DAC for device
> [    1.553569] r8169 0000:00:09.0: no PCI Express capability
> [    1.559063] r8169 0000:00:09.0: VPD access disabled, enabling
> [    1.565822] r8169 0000:00:09.0: MAC address found in EEPROM: 00:30:18:b0:25:c2
> [    1.573873] eth0: RTL8169sc/8110sc at 0xbf6f8000, 00:00:00:00:25:c2, XID 18000000 IRQ 10
> 
> [    1.582877] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
> [    1.595795] r8169 0000:00:0b.0: PCI INT A -> Link[LNKD] -> GSI 11 (level, low) -> IRQ 11
> [    1.604039] r8169 0000:00:0b.0: PCI: Disallowing DAC for device
> [    1.610089] r8169 0000:00:0b.0: no PCI Express capability
> [    1.615581] r8169 0000:00:0b.0: VPD access disabled, enabling
> [    1.622336] r8169 0000:00:0b.0: MAC address found in EEPROM: 00:30:18:b0:25:c3
> [    1.630854] eth1: RTL8169sc/8110sc at 0xbf6fc000, 00:00:00:00:25:c3, XID 18000000 IRQ 11
> 
> If I set the MAC address to the correct value it then ignores packets 
> sent to it and I have to use promiscuous mode.

Ah, I thought I have broken hardware. I have similar problem, my mac is
initially all zeroes. When I set it up, it works until suspend. After that I
need to unbind the driver, bind it again, and it works then (mac is still the
set one).

I'm out of the notebook right now, but it is 10ec:8168:
06:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168B PCI
Express Gigabit Ethernet controller (rev 01)
	Subsystem: ASUSTeK Computer Inc. Unknown device 11f5

I used it perfectly far later than 2.6.24 (maybe 2.6.26?), 2.6.27 is yet
defunct. This should be perfectly bisectable, would you, Simon? If this is not
fixed already -- I don't think so, mmotm few days ago is still broken. Francois,
anybody, does this ring bells anywhere?
