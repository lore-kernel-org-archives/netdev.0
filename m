From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169: Long link becomes ready times
Date: Sat, 22 Apr 2017 14:10:59 +0200
Message-ID: <20170422121059.GA7282@electric-eye.fr.zoreil.com>
References: <1492851908.2760.222.camel@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>,
        netdev@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>
To: Paul Menzel <paulepanter@users.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:32845 "EHLO
        violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1036624AbdDVMLO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Apr 2017 08:11:14 -0400
Content-Disposition: inline
In-Reply-To: <1492851908.2760.222.camel@users.sourceforge.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul Menzel <paulepanter@users.sourceforge.net> :
[...]
> The ASRock E350M1 has a Realtek ethernet controller.
> 
> It takes almost three seconds for the link to become ready. This is
> noticeable after resume from suspend, where the user wants to continue
> working but first has to wait for the network.
> 
> This test is done with Linux 4.10.
[...]
> The test below is done, removing the module, and then inserting it.
> 
> ```
> Apr 22 10:56:11.919311 myasrocke350m1 kernel: r8169 0000:03:00.0 eth0: RTL8168e/8111e at 0xf82ad000, bc:5f:f4:c8:d3:98, XID 0c200000 IRQ 26
> Apr 22 10:56:11.920631 myasrocke350m1 kernel: r8169 0000:03:00.0 eth0: jumbo features [frames: 9200 bytes, tx checksumming: ko]
> Apr 22 10:56:11.967396 myasrocke350m1 kernel: r8169 0000:03:00.0 eth6: renamed from eth0
> Apr 22 10:56:12.064323 myasrocke350m1 kernel: IPv6: ADDRCONF(NETDEV_UP): eth6: link is not ready
> Apr 22 10:56:12.179106 myasrocke350m1 kernel: r8169 0000:03:00.0: firmware: direct-loading firmware rtl_nic/rtl8168e-2.fw
> Apr 22 10:56:12.247858 myasrocke350m1 kernel: r8169 0000:03:00.0 eth6: link down
> Apr 22 10:56:12.248593 myasrocke350m1 kernel: IPv6: ADDRCONF(NETDEV_UP): eth6: link is not ready
> Apr 22 10:56:14.992108 myasrocke350m1 kernel: r8169 0000:03:00.0 eth6: link up
> Apr 22 10:56:14.993299 myasrocke350m1 kernel: IPv6: ADDRCONF(NETDEV_CHANGE): eth6: link becomes ready
> ```
> 
> Is it possible to get this well below one second?

Gross as it is, the link detection is already irq driven. Most currently
used delays - see grep -E '(sleep|delay)' drivers/.../r8169.c - are
supposed to be busy waiting loops with a moderate (well...) delay per
loop. The iteration bound is not expected to make a difference.

So, unless there is a big crawling sleep/delay hidden somewhere, this part
of the r8169 driver should not induce huge delays.

Realtek does not communicate hardware documentation, neither programming
specification nor known bugs. Some phy related pieces of material may be
found on their site but you would have to experiment a lot to check if
things can behave differently.

I also experience ~3s link down / link up transition with a 8168c when
connected to a 3Com 4200G. Same 2~3s figures with an intel 82578dc.
It looks similar with a 82574l.

I've never aimed at well below one second (500 ms ?) reliable autoneg.
The phy man may have a different vision.

-- 
Ueimor
