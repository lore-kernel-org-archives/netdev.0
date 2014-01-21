From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 won't transmit with 3.12
Date: Wed, 22 Jan 2014 00:36:30 +0100
Message-ID: <20140121233630.GA3214@electric-eye.fr.zoreil.com>
References: <20140121000615.GA30495@enc.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>,
	netdev@vger.kernel.org
To: Craig Small <csmall@enc.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:34868 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754151AbaAUXgo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 18:36:44 -0500
Content-Disposition: inline
In-Reply-To: <20140121000615.GA30495@enc.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Craig Small <csmall@enc.com.au> :
[...]
> It's a new setup so it might of never worked. It's not likely to be a
> hardware problem as its three different devices.

You may check that the onboard nic device does not even work when the
extra PCI-e card aren't plugged.

> I've sent what I think you might need for starters, but if there
> is extra stuff you'd like to see, let me know.

A complete dmesg including the XID lines that the r8169 driver prints
would be welcome.

> The problem shows up the same, the TX dropped counter increments.
> I'm not sure why 42 packets made it out (or even if they really did)
> Receive works fine, I can even start up wireshark and see packets
> pass by.
> 
> eth0      Link encap:Ethernet  HWaddr 00:e0:4c:80:66:57  
>           inet addr:192.168.1.222  Bcast:192.168.1.255  Mask:255.255.255.0
>           inet6 addr: fe80::2e0:4cff:fe80:6657/64 Scope:Link
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:8252 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:42 errors:0 dropped:8029 overruns:0 carrier:0

There are very few places where the r8169 driver modifies tx_dropped.

Please increase the driver verbosity with the 'msglvl' option of ethtool.

[...]
> ethtool -S shows a similar story, not sure if the rx_missed counter
> is another problem:

It seems safe to ignore as long as it does not change after startup.

-- 
Ueimor
